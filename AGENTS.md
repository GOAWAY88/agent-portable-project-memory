# Agent instructions

This repository dogfoods the Agent-Portable Project Memory Framework.

Before substantial work:

1. Read `.ai/NOW.md` and `.ai/INDEX.md`.
2. Inspect `git status`, branch, and recent commits.
3. Read only the relevant specification, docs, and active change files.
4. Verify important assumptions against scripts, tests, and executable reality.

Project-memory maintenance is part of every non-trivial task that changes code, configuration, interfaces, architecture, tests, or documented behavior; the user does not need to request it separately. Before substantive edits, create or reuse one suitable active change. Keep its proposal, design, tasks, and evidence synchronized with the implementation; promote durable facts to `.ai/knowledge/` and durable decisions to individual ADRs; update `.ai/NOW.md` before handoff. In the final response, name the memory files changed.

Small, behavior-neutral edits do not require a new active change. Do not record ordinary conversation, speculation, secrets, or claims that have not been verified; mark uncertain claims explicitly instead. Do not recursively load `.ai/archive/` or treat summaries as higher authority than source and evidence.

Before handoff, run `bash -n scripts/*.sh tests/*.sh`, `./scripts/validate.sh .`, `./tests/test_v01_baseline.sh`, `./tests/test_v01_structure.sh`, `./tests/test_memory_integrity.sh`, `./tests/test_lifecycle_closeout.sh`, and `./tests/test_retrieval_index.sh`; after a Git commit exists, run `./scripts/close-provenance.sh .` (or `./scripts/checkpoint.sh .`) to bind unresolved provenance placeholders to that commit; update `.ai/NOW.md`, tasks, and evidence, and record durable decisions as individual ADRs.
