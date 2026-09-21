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
3. Update active tasks and concise evidence (command, result, commit, conditions).
4. Record durable decisions as individual ADRs and promote verified knowledge.
5. Update `NOW.md` with current state, blockers, next action, and verified commit.
6. Archive a completed change when appropriate.

Agents must state unresolved uncertainty rather than manufacturing a result. Concurrent agents should prefer separate change/ADR files; V0.1 does not solve simultaneous edits to the same Markdown file.
