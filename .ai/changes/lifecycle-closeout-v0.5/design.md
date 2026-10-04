# Design: lifecycle-closeout-v0.5

## Approach

Use a Bash helper with a preflight phase, a temporary backup of route files, a directory move, deterministic route rewrites, and a post-update `validate.sh`. On any write or validation failure, restore the route files and move the change back. `--check` runs preflight only.

## Interfaces and affected paths

- `scripts/archive-change.sh`: explicit archive and `--check` interface.
- `.ai/NOW.md`: active route becomes `none`, with generic next action.
- `.ai/INDEX.md`: current-work row becomes a NOW pointer.
- `.ai/decisions/*.md`: exact `.ai/changes/<name>/` evidence references move to `.ai/archive/changes/<name>/`.
- `.ai/changes/<name>/` → `.ai/archive/changes/<name>/`: lifecycle move.
- `tests/test_lifecycle_closeout.sh`, CI, V0.5 spec, README, commands, roadmap, and handoff docs.

## Tradeoffs

The helper updates only mechanical routing and leaves semantic task summaries to the agent. It refuses an existing archive destination rather than guessing whether a repeated run is safe.

## Risks

The helper cannot know whether an ADR reference is semantically related unless it contains the exact active-change path; exact replacement avoids broad historical rewrites. A user still must review and commit the resulting working-tree changes.

## Rejected alternatives

- Automatically creating a commit would alter user history and hide the route changes from review.
- Moving a change first and fixing routes later permits invalid intermediate states and was the dogfood failure.
- Silently treating an existing destination as success would mask duplicate or divergent history.
