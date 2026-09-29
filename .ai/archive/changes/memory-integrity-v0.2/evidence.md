# Evidence: memory-integrity-v0.2

| Date | Branch/SHA | Command or observation | Result |
|---|---|---|---|
| 2026-09-24 | main / 3c2a31f26754f164312e2deafa5e030a01d3c016 | V0.1-alpha baseline inspected | Existing validator covered only existence, active artifacts, ADR filename, and tracked runtime samples; integrity expansion required |
| 2026-09-24 | main / working tree | `bash -n scripts/*.sh tests/*.sh` | Passed on local Bash |
| 2026-09-24 | main / working tree | `./scripts/validate.sh .` | Passed: NOW/INDEX, metadata, provenance, active artifacts, archival rule, and runtime tracking checks |
| 2026-09-24 | main / working tree | `./tests/test_v01_baseline.sh` | Passed: frozen V0.1-alpha contract |
| 2026-09-24 | main / working tree | `./tests/test_v01_structure.sh` | Passed: initialization, idempotence, conflict preservation, generated validation, and ignore behavior |
| 2026-09-24 | main / working tree | `./tests/test_memory_integrity.sh` | Passed: broken links, invalid statuses, unresolvable commits, missing evidence, completed changes, missing NOW fields, and ADR failures |
| 2026-09-24 | main / working tree | `.github/workflows/ci.yml` | Added PR/push matrix for Ubuntu and macOS system Bash |
| 2026-09-29 | main / a2f1d730378f41d646c865be67ac9cb011654dc9 + working tree | GitHub run showed `validate.sh` could not resolve the V0.1 baseline in shallow checkout | Added `fetch-depth: 0` to `actions/checkout`; all local validation suites passed |
| 2026-09-29 | main / df9b2d20718e624ad1a0b20ee9e7ca7836d2e025 | [GitHub Actions run](https://github.com/GOAWAY88/agent-portable-project-memory/actions/runs/36504999390) for push `df9b2d2` | Passed on `ubuntu-latest` and `macos-latest`; syntax, validator, baseline, structure, integrity, and whitespace checks all succeeded |
