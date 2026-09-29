---
id: KNOW-COMMANDS
status: current
updated: 2026-09-24
verified_at_commit: 3c2a31f26754f164312e2deafa5e030a01d3c016
---
# Commands

| Purpose | Command |
|---|---|
| Validate structure | `./scripts/validate.sh .` |
| Run tests | `./tests/test_v01_structure.sh` |
| Run integrity tests | `./tests/test_memory_integrity.sh` |
| Check frozen baseline | `./tests/test_v01_baseline.sh` |
| Shell syntax | `bash -n scripts/*.sh tests/*.sh` |
| Handoff context | `./scripts/context.sh .` |
| Checkpoint checklist | `./scripts/checkpoint.sh .` |
