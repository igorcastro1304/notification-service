# PLAN – notification-service

> Living document. Describe the project timeline and goals; each step stage will be at roadmap in the end of document.
> New decisions goes in "Decision with date and motivation"

## Goal

Event-driven notification service, in Golang. Receives notification requests from an API,
using astnchronous processing and delivery through channels (simulated e-mail and webhooks), featuring:

- no missed notification, even during component failures;
- no duplicate notification with effect (delivery at least once + idempotency);
- retry with backoff and dead-letter queue;
- observability (metrics, traces and structured logs).

It's a portfolio project: clear code, tests and documentation are as important as features.

## Arquitetura

```
client ──HTTP/gRPC──▶ api ──(1 transaction)──▶ Postgres: notifications + outbox
                                                      │
                                     relay ◀──────────┘  read pending outbox
                                       │
                                       ▼
                         Redpanda: notifications.requested
                                       │
                                       ▼
                    worker ──▶ Redis (idempotency) ──▶ delivery (fake email / webhook)
                       │                                       │
                       ├── destination failure ──▶ notifications.retry (backoff) ──▶ worker
                       ├── retry failed ──▶ notifications.dlq + status failed
                       └── success ──▶ Postgres: status sent
```

### Binaries

| Binary | Responsability | Depends on |
| --- | --- | --- |
| `cmd/api` | Validate requests, record notification + outbox event in a transaction, check status | Postgres |
| `cmd/relay` | Publish pending events in Redpanda's outbox and mark as published | Postgres, Redpanda |
| `cmd/worker` | Consumes events, ensure idempotency, deliveries, update status, schedule retry/DLQ | Redpanda, Redis, Postgres |

The `api` don't talk with Redpanda: continues accepting requests event with broker out.

## Package structure

```
cmd/{api,relay,worker}/main.go   # only dependency injection and shutdown
internal/
  config/         # enviroment variables reading
  domain/         # entities, validation, events (without project's dependencies)
  app/            # usecases + interfaces (ports) needed
  storage/postgres/
  queue/kafka/
  idempotency/    # Redis
  delivery/       # webhook, fake email, router per channel
  relay/
  worker/         # processor, backoff
  transport/http/ # handlers REST
  transport/grpc/
  telemetry/
migrations/
proto/            # gRPC contracts (step 7)
```

**Dependencies' rules:** imports target to inside. `domain` don't import anything from project;
`app` import `domain` and declare interfaces; plugs (`storage`, `queue`, `idempotency`,
`delivery`) implement these interfaces; only `cmd/*` knows concrete implementations.

## Data Model

- `notifications`: id (UUID), idempotency_key (UNIQUE), channel, payload (JSONB), status
  (pending | sent | failed), attempts, last_error, created_at, updated_at.
- `outbox`: id (BIGSERIAL), event_id (UUID UNIQUE), topic, key, payload (JSONB), created_at,
  published_at (NULL = pendente). Índice parcial em `published_at IS NULL`.

## Events

Common wrapping: `event_id`, `type`, `version`, `occurred_at`, `attempt`, `not_before`, `data`.

| Topic | Publish | Consume | Key |
| --- | --- | --- | --- |
| `notifications.requested` | relay | worker | notification_id |
| `notifications.retry` | worker | worker | notification_id |
| `notifications.dlq` | worker | manual inspection | notification_id |

6 partitions per topic; the key assure notification's order.

## API

| Method | Route | Response |
| --- | --- | --- |
| GET | `/healthz` | 200 `{"status":"ok"}` |
| POST | `/v1/notifications` | 202 `{id}` (new) · 200 `{id}` (repeated idempotency_key) · 400 (invalid) |
| GET | `/v1/notifications/{id}` | 200 with status · 404 |

## Assurances and failures

- **At least once delivery** + worker's idempotency (Redis) and header `Idempotency-Key` in webhook.
- **Outbox pattern:** save notification and the event in the same transaction; after, the relay publishes it.
- **Destination error** → scheduled retry and offset commit. **Infrastructure error** → without commit, the message is re-read.
- **Redis out** → closed failure: the worker stop processing in order to prevent duplication.
- Each failure scenario should have an integration test (step 4).

## Convenções

- Go 1.25+; standard libraries first, new dependencies only with reason.
- Chosen libraries: pgx/v5, franz-go, go-redis/v9, testify, testcontainers-go, errgroup.
- Config via enviroment variables only (`.env.example` documents all).
- Logs with `log/slog` in JSON. `context.Context` as first parameter in I/O.
- Tests: unit tests with fakes in memory; integration with Testcontainers; table-driven when there is several cases.
- Commits in Conventional Commits; one task = one branch = one PR.
- CI needs to pass (vet, testes com -race, lint, build) before any merge in main.

## Roadmap

Each step become tasks in `docs/tasks/`. Mark `[x]` when step is concluded and merged.

### Step 0 – Foundation
- [x] docker-compose with Postgres, Redpanda, Redis and Console
- [x] Makefile and .env.example
- [x] `cmd/api` with `/healthz`
- [ ] `/healthz`'s tests (task 001)
- [ ] Initial reading (task 002)
- [ ] CI in GitHub Actions: vet, test, lint, build

### Step 1 – Domain and database
- [ ] `internal/domain`: Notification, Status, Channel, validation, event wrapper
- [ ] Initial migration (`notifications`, `outbox`)
- [ ] `internal/storage/postgres`: InsertIfAbsent, outbox, transaction helper
- [ ] Integration test with Testcontainers

### Step 2 – API
- [ ] `internal/app`: Create and Get
- [ ] `internal/transport/http`: POST and GET `/v1/notifications`
- [ ] `internal/config` and API graceful shutdown

### Step 3 – Relay and worker (MVP)
- [ ] Kafka's Producer + `cmd/relay`
- [ ] Consumer + processor with idempotência in Redis + fake e-mail
- [ ] Visible `sent` status in GET → **Concluded MVP**

### Step 4 – Reliability
- [ ] Retry with exponencial backoff and jitter; DLQ
- [ ] Delivery by webhook with `Idempotency-Key` and timeout
- [ ] Integration tests for each failure scenario
- [ ] `make replay-dlq`

### Step 5 – Observability
- [ ] OpenTelemetry: unique trace API → Kafka → worker
- [ ] Prometheus metrics + dashboard Grafana

### Step 6 – Scale and load
- [ ] Rate limiting per client (token bucket no Redis)
- [ ] Load test with k6; numbers in READ.me

### Step 7 – gRPC
- [ ] `.proto`, buf and code generated
- [ ] Server gRPC + grpc-gateway serving the REST

### Step 8 – Kubernetes
- [ ] Dockerfiles multi-stage, chart Helm, local cluster with kind, HPA in workers

## Out of scope

- Clients authentication and multi-tenancy.
- Real e-mail delivery (the e-mail channel is simulated).
- Cloud deploy (can become a step in the future).

## Decisions

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-10 | Redpanda instead of Kafka in localhost | Compatible with Kafka's API, lighter, without ZooKeeper |
| 2026-10 | Outbox pattern instead publishing from API | Prevents the loss or creation of events when the API goes down between the commit and the publication. |
| 2026-10 | gRPC only after MVP REST | Validate the end-to-end flow before adding code generation |