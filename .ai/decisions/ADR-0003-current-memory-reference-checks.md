---
id: ADR-0003-current-memory-reference-checks
status: accepted
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: dfe1021fc34e943d670edd19353c6b8110bfd7b2
supersedes: null
superseded_by: null
evidence: .ai/changes/reference-integrity-v0.7/evidence.md
---
# ADR-0003-current-memory-reference-checks: Check current routes without rewriting history

## Context

APMF archives completed changes by moving `.ai/changes/<name>/` to `.ai/archive/changes/<name>/`. A current Markdown file that keeps the old route can silently mislead an agent even though the archive is healthy.

## Decision

Check local references in current `.ai/` Markdown and ADR evidence front-matter, but do not scan or rewrite historical archives. A missing active-change route is reported as stale when its archive counterpart exists; all repairs remain explicit and user-reviewed.

## Consequences

- CI and handoff checks catch broken current routes early.
- Historical evidence remains immutable and is not judged by current routing rules.
- The checker is intentionally lexical and portable; it does not resolve arbitrary prose or URLs.

## Alternatives considered

- **Rewrite stale paths automatically:** rejected because a path's intended replacement can be ambiguous.
- **Validate every Markdown file including archives:** rejected because archives are historical evidence, not current routing.
- **Check remote URLs:** rejected because network availability is not memory integrity and would make CI nondeterministic.

## Evidence and provenance

See `.ai/changes/reference-integrity-v0.7/evidence.md` and the reference-integrity tests.
