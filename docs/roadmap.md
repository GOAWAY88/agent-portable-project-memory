# Roadmap

## V0.1 (frozen alpha baseline)

Portable Markdown, layered routing, active changes, provenance, authority/staleness rules, archives, and minimal POSIX-friendly helpers. The compatibility contract is frozen in `spec/baselines/v0.1-alpha.md`.

## V0.2 (Memory Integrity)

Structural and provenance validation, negative tests, idempotence checks, and GitHub CI. Completed changes must leave the active area; broken routes and unresolvable evidence commits fail early.

## V0.3 (Project Profiles)

Init-time profiles (`template/profiles/software|paper/`) seed domain-appropriate knowledge and a declarative `.ai/profile.md` manifest; `validate.sh` checks the manifest-declared required knowledge set and falls back to the frozen software defaults when no manifest exists. Profile selection is explicit; detection may only suggest. Specified in `spec/v0.3-profiles.md`.

## V0.4 (Provenance Closeout)

The optional `scripts/close-provenance.sh` helper binds unresolved `verified_at_commit` placeholders in current memory to an existing full `HEAD` SHA. `checkpoint.sh` invokes it for initialized projects; it is idempotent, preserves existing provenance, and never edits semantic content or creates commits. Specified in `spec/v0.4-provenance-close.md`.

## V0.5 (Lifecycle Closeout)

The optional `scripts/archive-change.sh` helper preflights and atomically archives completed active changes while repairing NOW, INDEX, and exact ADR evidence routes. It validates the result, rolls back on failure, never creates commits, and refuses an existing archive destination. Specified in `spec/v0.5-lifecycle-closeout.md`.

## V0.6 (Derived Retrieval Index)

The optional `scripts/index-memory.sh` helper rebuilds a disposable SQLite FTS5/BM25 index from canonical `.ai/**/*.md` files. The database is ignored, atomically replaced, and never authoritative; Python/SQLite FTS5 is optional. Specified in `spec/v0.6-retrieval-index.md`.

## V0.7 (Current Reference Integrity)

The read-only `scripts/check-references.sh` helper detects missing local routes and stale `.ai/changes/` references after archival; `validate.sh` also verifies local ADR evidence paths. Historical archives remain excluded. Specified in `spec/v0.7-reference-integrity.md`.

## V0.8 (Handoff Gate)

The read-only `scripts/doctor.sh` composes validation, reference, provenance, Git-state, and optional retrieval-freshness checks; `checkpoint.sh` invokes it after its explicit provenance closeout. Strict mode turns warnings into failures, and an end-to-end lifecycle test verifies the complete handoff path. Specified in `spec/v0.8-handoff-gate.md`.

## Possible later versions

- dependency-aware task graph
- agent adapters that remain clients of canonical files
- optional MCP or cloud integrations
- additional profiles (data-engineering, hardware/firmware) contributed as new `template/profiles/` directories

These must preserve the canonical repository format and remain opt-in.
