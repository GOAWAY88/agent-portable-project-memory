---
id: KNOW-COMMANDS
status: current
updated: 2026-10-04
verified_at_commit: unknown
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
| Close unresolved provenance after a commit | `./scripts/close-provenance.sh /path/to/project` |
| Check provenance without writing | `./scripts/close-provenance.sh --check /path/to/project` |
| Init a project (default software profile) | `./scripts/init.sh /path/to/project` |
| Init with a profile | `./scripts/init.sh --profile paper /path/to/project` |
