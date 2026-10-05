---
id: handoff-gate-v0.8-design
status: draft
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: unknown
---
# Design: Unified handoff health gate

## Approach

`doctor.sh` resolves a target Git project, invokes existing read-only checks, and adds lightweight state diagnostics. Errors come from failed canonical validation, reference integrity, or unresolved provenance. Warnings cover dirty Git state, declared/current branch mismatch, non-empty blockers, and an absent, unreadable, or stale optional retrieval index.

The default exit code ignores warnings so projects without optional retrieval remain valid. `--strict` promotes warnings to failure for release-quality handoffs. Retrieval metadata is opened read-only and compared with `HEAD`; it never rebuilds the database.

`checkpoint.sh` remains the explicit write boundary for provenance closeout, then invokes the doctor. The doctor itself never calls a mutating helper.

## Tradeoffs

- A single command improves operational usability but intentionally exposes warnings rather than hiding optional state.
- Git dirtiness is a warning because checkpointing commonly occurs before the final commit; strict mode is available after committing.
- Retrieval freshness compares its recorded commit with `HEAD`, so uncommitted Markdown is covered indirectly by the dirty-tree warning.

## Risks

- Helper output can be noisy when a check fails; preserving it is preferable to losing the actionable diagnostic.
- A project may intentionally have blockers or a stale optional index; default warning semantics prevent false hard failures.

## Rejected alternatives

- **Make checkpoint silently repair every issue:** rejected because semantic memory cannot be inferred safely.
- **Make retrieval mandatory:** rejected because canonical Markdown must remain usable without Python/SQLite.
- **Only document a command list:** rejected because command drift is exactly what the unified gate should prevent.
