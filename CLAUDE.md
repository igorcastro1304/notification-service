# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

`notification-service` has not been started yet. It holds only a `LICENSE`, a Go `.gitignore` (from the GitHub Go template), and an empty `.env`. There is no `go.mod`, no source code, no build tooling and no tests.

The `.gitignore` shows the project is meant to be written in Go. `.env` is gitignored, so local configuration and secrets go there.

## Commands

No project-specific build or test tooling exists yet. Once a `go.mod` is added, the standard Go commands apply:

```bash
go build ./...                          # build
go test ./...                           # run all tests
go test ./path/to/pkg -run TestName     # run a single test
go vet ./...                            # static checks
```

Update this file once the module layout, entry points and any Makefile, Docker or CI setup exist.
