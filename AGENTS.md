# Agent instructions

This repository dogfoods the Agent-Portable Project Memory Framework.

Before substantial work:

1. Read `.ai/NOW.md` and `.ai/INDEX.md`.
2. Inspect `git status`, branch, and recent commits.
3. Read only the relevant specification, docs, and active change files.
4. Verify important assumptions against scripts, tests, and executable reality.

Do not recursively load `.ai/archive/` or treat summaries as higher authority than source and evidence. Keep changes scoped, update the active change and evidence as work progresses, and never put secrets in project memory.

Before handoff, run `bash -n scripts/*.sh tests/*.sh`, `./scripts/validate.sh .`, `./tests/test_v01_baseline.sh`, `./tests/test_v01_structure.sh`, and `./tests/test_memory_integrity.sh`; update `.ai/NOW.md`, tasks, and evidence, and record durable decisions as individual ADRs.
