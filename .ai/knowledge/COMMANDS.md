---
id: KNOW-COMMANDS
status: current
updated: 2026-09-29
verified_at_commit: 5431ff3d7d8a07802e391c6d9ca3d8723d05715e
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
| Init a project (default software profile) | `./scripts/init.sh /path/to/project` |
| Init with a profile | `./scripts/init.sh --profile paper /path/to/project` |
