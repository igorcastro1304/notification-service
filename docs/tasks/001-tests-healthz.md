# 001 – `/healthz` Tests

## Objective
Make the API router testable and add test coverage for `/healthz`.

## Context
- Currently, the mux is created inside `main()` in `cmd/api/main.go`, which prevents testing without starting the server.

## Requirements
- Extract router creation into `func newRouter() http.Handler` in `cmd/api/router.go`.
- Update `main()` to use `newRouter()`.
- `GET /healthz` must return status code `200`, `Content-Type: application/json`, and the body `{"status":"ok"}`.
- Replace `log.Println(http.ListenAndServe(...))` with `log.Fatal(...)`.
- Add the `test` target to the Makefile: `go test -race ./...` (an authorized exception to the Makefile rule).

## Out of Scope
- Configuration through environment variables.
- Graceful shutdown.
- Any packages under `internal/`.

## Acceptance Criteria
- [ ] Table-driven tests in `cmd/api/router_test.go` using `httptest`, covering:
  - `GET /healthz` → `200` and body `{"status":"ok"}`
  - `POST /healthz` → `405`
  - `GET /non-existent-route` → `404`
- [ ] `make test` passes.
- [ ] `curl -i localhost:8080/healthz` continues to return `200`.

## Notes