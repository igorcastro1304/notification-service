# 002 – Initial README

## Objective
Create a README that explains the project and allows anyone to run it from scratch.

## Requirements
- Include the following sections: brief description, target architecture (Mermaid diagram), current status, prerequisites (Docker, Go, make), how to run, how to test, and roadmap.
- The roadmap must follow the stages defined in `docs/PLAN.md`, marking completed items accordingly.
- All commands mentioned must match the current Makefile.

## Out of Scope
- Documenting endpoints that do not yet exist as if they were already implemented.

## Acceptance Criteria
- [ ] Following the README instructions from a clean clone, `make up` and `make run-api` work.
- [ ] `curl -i localhost:8080/healthz` returns `200`, as stated in the README.
- [ ] No commands are referenced unless they exist in the Makefile.