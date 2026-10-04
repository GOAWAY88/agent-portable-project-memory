# Design: provenance-close-v0.4

## Approach

Use a small Bash helper and an `awk` front-matter state machine. The helper resolves the target's full `HEAD` SHA, rewrites only supported placeholder values in the canonical current-memory files, and uses a temporary file plus `cmp`/`mv` for idempotent safe writes. `checkpoint.sh` calls it after confirming `.ai/NOW.md` exists.

## Interfaces and affected paths

- `scripts/close-provenance.sh`: explicit closeout and `--check` interface.
- `scripts/checkpoint.sh`: normal handoff path invokes closeout.
- `spec/v0.4-provenance-close.md`, `docs/agent-handoff.md`, `docs/roadmap.md`, README, and command knowledge: documented behavior.
- `tests/test_v01_structure.sh`: first-commit, unborn, idempotence, check-mode, and preservation coverage.

## Tradeoffs

Updating only provenance placeholders is safe to automate and keeps semantic verification with agents/humans. Using full SHAs makes metadata independently resolvable across platforms and avoids ambiguity from short hashes.

## Risks

The helper creates a working-tree edit after the first commit; the user must commit that metadata update separately. It intentionally does not update `updated` dates or evidence prose, so a project still needs a normal semantic handoff review.

## Rejected alternatives

- Automatically creating a commit would alter user history and exceed the helper's scope.
- Rewriting every `verified_at_commit` to current HEAD would destroy valid historical provenance.
- A Git hook would not run reliably for all agents or manual workflows; checkpoint remains explicit and portable.
