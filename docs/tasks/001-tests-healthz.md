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
- [x] Table-driven tests in `cmd/api/router_test.go` using `httptest`, covering:
  - `GET /healthz` → `200` and body `{"status":"ok"}`
  - `POST /healthz` → `405`
  - `GET /non-existent-route` → `404`
- [x] `make test` passes.
- [ ] `curl -i localhost:8080/healthz` continues to return `200`.

## Notes
- **Literal body write:** the handler writes `{"status":"ok"}` as a literal, not with `json.NewEncoder`. The encoder appends a trailing `\n`, which would break the exact body match in the test.
- **`log` instead of `log/slog`:** kept `log.Fatal` as the task requires, since `slog` has no `Fatal`. Migrating to `slog` (`slog.Error` + `os.Exit(1)`) is left for a future task.
- **`log.Fatal` already present:** `main.go` already used `log.Fatal(http.ListenAndServe(...))`, so that requirement needed no change.
- **Content-Type in tests:** the acceptance criteria mention only status and body, but the GET case also checks `Content-Type: application/json`, which is listed in the requirements.
- **Test naming:** a single table-driven `TestRouter_Healthz` with subtests describing each behavior (`returns_ok_on_GET`, `rejects_POST_with_method_not_allowed`, `returns_not_found_for_unknown_route`).
- **Out of scope:** `HEAD /healthz` (the Go 1.22+ mux already answers 200) and the `Allow: GET, HEAD` header on the 405 response were not tested.
- **TDD:** tests came first. They failed at compile time (`newRouter` undefined), then on behavior (empty body and Content-Type with the old handler), and then the implementation made them pass.
- **Pending:** the `curl` criterion was not verified during implementation because port `:8080` was already in use by another process. Verify with `make run-api` + `curl -i localhost:8080/healthz`.
