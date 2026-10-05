---
id: KNOW-COMMANDS
status: current
updated: 2026-10-04
verified_at_commit: be8807e1bdcf131baca269742af3f8504b1ea8c1
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
| Archive a completed change | `./scripts/archive-change.sh /path/to/project <change>` |
| Check archive preflight without writing | `./scripts/archive-change.sh --check /path/to/project <change>` |
| Check optional FTS5 support | `./scripts/index-memory.sh --check /path/to/project` |
| Rebuild optional retrieval index | `./scripts/index-memory.sh /path/to/project` |
| Search optional retrieval index | `./scripts/index-memory.sh --query <term> /path/to/project` |
| Check current-memory references | `./scripts/check-references.sh /path/to/project` |
| Init a project (default software profile) | `./scripts/init.sh /path/to/project` |
| Init with a profile | `./scripts/init.sh --profile paper /path/to/project` |
