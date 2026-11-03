# notification-service — Copilot Instructions

## 1. Project Overview

This is a portfolio project developed to learn Go backend engineering and event-driven architecture.

The project must evolve incrementally according to the roadmap and tasks defined in `docs/`.

Always treat the current implementation as the source of truth. Planned features are not necessarily implemented.

## 2. Technology Stack

- Go 1.23+
- PostgreSQL
- Redpanda (Kafka-compatible)
- Redis
- Docker Compose
- Make

Prefer the Go standard library over external dependencies.

Ask for approval before introducing new dependencies.

## 3. Development Principles

- Follow idiomatic Go conventions.
- Keep implementations simple and maintainable.
- Avoid unnecessary abstractions.
- Respect the existing project architecture.
- Do not implement functionality outside the current task.
- Do not refactor unrelated code.
- Do not assume that roadmap items have already been implemented.
- Preserve backward compatibility unless the task explicitly requires otherwise.

## 4. Testing Guidelines

- Use `go test -race ./...` for the complete test suite.
- Use `net/http/httptest` for HTTP handler tests.
- Prefer table-driven tests when multiple cases exist.
- Use descriptive test names, such as `TestHealthz_ReturnsOK`.
- Do not require a real HTTP server for unit tests.
- Do not remove or weaken existing tests to make them pass.

## 5. Project Commands

The Makefile is the source of truth for project commands.

Before documenting or executing a project-specific command, inspect the current Makefile.

Never invent Makefile targets or assume that a command exists.

## 6. Task Execution Workflow

Before implementing any task:

1. Read `docs/PLAN.md`.
2. Read the complete task specification in `docs/tasks/`.
3. Inspect the relevant source code and configuration.
4. Identify the acceptance criteria.
5. Present an implementation plan before modifying files.

After implementation:

1. Verify every acceptance criterion.
2. Execute the relevant tests and validation commands.
3. Review the final Git diff.
4. Report modified files, commands executed, test results and remaining issues.

## 7. Scope Control

- Work on only the task explicitly requested by the user.
- Do not implement future roadmap stages.
- Do not modify task specifications unless explicitly requested.
- Do not update dependencies unnecessarily.
- Ask for clarification when requirements conflict or are ambiguous.

## 8. Learning and Explanations

This project is also intended for learning.

Explain important implementation decisions, architectural trade-offs and Go concepts when presenting the results.

Do not hide implementation details behind unnecessary abstractions.