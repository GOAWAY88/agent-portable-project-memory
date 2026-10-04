# Agent handoff protocol

## BOOTSTRAP

1. Read `AGENTS.md`, `.ai/NOW.md`, and `.ai/INDEX.md`.
2. Inspect `git status`, current branch, and recent commits.
3. Read the named active change and only relevant knowledge/ADRs.
4. Inspect relevant source and configuration.
5. Verify high-impact assumptions; summaries never outrank executable reality.
6. Summarize reconstructed project, milestone, active work, blockers, decisions, next action, and validation before major edits.

Do not recursively read `.ai/archive/` or all of `.ai/**`.

## CHECKPOINT

1. Inspect diff/status and branch/commit.
2. Run relevant tests and `scripts/validate.sh`.
3. Run `scripts/close-provenance.sh <project>` after a commit exists; `scripts/checkpoint.sh <project>` performs this closeout automatically for initialized APMF projects.
4. Run `scripts/archive-change.sh <project> <change>` only after all tasks are DONE; review its route changes before committing.
5. Update active tasks and concise evidence (command, result, commit, conditions).
6. Record durable decisions as individual ADRs and promote verified knowledge.
7. Update `NOW.md` with current state, blockers, next action, and verified commit.
8. Archive a completed change when appropriate.

Agents must state unresolved uncertainty rather than manufacturing a result. Concurrent agents should prefer separate change/ADR files; V0.1 does not solve simultaneous edits to the same Markdown file.
