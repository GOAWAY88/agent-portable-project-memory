---
id: ADR-0004-read-only-doctor-gate
status: accepted
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: 61ce4151555dbeafc924292034fa210f909aa1a2
supersedes: null
superseded_by: null
evidence: .ai/archive/changes/handoff-gate-v0.8/evidence.md
---
# ADR-0004-read-only-doctor-gate: Separate diagnosis from mutation

## Context

APMF's helpers now cover provenance closeout, lifecycle archival, reference validation, and derived retrieval. Combining them into a handoff gate could make operation easier, but a diagnostic command that silently edits memory would obscure provenance and surprise users.

## Decision

`doctor.sh` is strictly read-only. It composes existing read-only checks and reports errors, warnings, and state summaries. `checkpoint.sh` retains the explicit provenance-closeout write step and then calls the doctor. Optional retrieval absence or staleness is a warning by default and becomes fatal only under `--strict`.

## Consequences

- Agents and humans get one repeatable health command before handoff.
- Diagnostic runs are safe in CI and cannot change canonical Markdown.
- Release gates can use strict mode, while ordinary projects remain valid without a retrieval database.

## Alternatives considered

- **Have doctor close provenance or rebuild indexes:** rejected because diagnostics should not mutate either canonical or derived state.
- **Treat every warning as an error:** rejected because dirty worktrees and optional retrieval are normal during development.
- **Keep checkpoint as a printed checklist only:** rejected because executable composition catches drift that prose cannot.

## Evidence and provenance

See `.ai/archive/changes/handoff-gate-v0.8/evidence.md` and the V0.8 handoff-gate tests.
