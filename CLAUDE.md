# notification-service
Golang event-driven notification service (portfolio project).
Goal architecture: API (REST, gRPC later) -> Postgres outbox -> Redpanda (Kafka) -> workers with idempotency in Redis.
Full plan in docs/PLAN.md; tasks in docs/tasks.

# Current state
- Only exists cmd/api with GET /healthz. Postgres, Redpand and Redis go up with docker compose, but the code don't use anybody.

# Commands
- make up / make down: up and down the infrastructure
- make test: go test -race ./...
- make run-api: run API in :8080

# Coding rules
- Go 1.25+, standard library when possible; ask before add external dependencies
- Tests HTTP with net/http/httptest, without up a real server
- Table-driven tests when exists more than one case
- Test's name describes the behavior: TestHealthz_ReturnsOK
- Logs with log/slog
- Wrapped errors with fmt.Errorf("...: %w", err)

# Documentation rules
- README in Portuguese/BR; everything else in docs/ (tasks, PLAN.md) in English
- Every command listed in the documentation should exist in Makefile and work

# Limits
- Don't make changes in docker-compose.yml, Makefile or .env.example without asking
- Don't create folders or packages that task doesn't demands
- A task is finished when make test passes

# Git
- Conventional Commits (feat:, fix:, test:, docs:, chore:)
- Don't make commits or pushes; propose the message and I commit