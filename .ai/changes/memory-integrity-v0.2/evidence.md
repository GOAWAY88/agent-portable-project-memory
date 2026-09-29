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
