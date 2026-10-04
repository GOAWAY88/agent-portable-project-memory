# Roadmap

## V0.1 (frozen alpha baseline)

Portable Markdown, layered routing, active changes, provenance, authority/staleness rules, archives, and minimal POSIX-friendly helpers. The compatibility contract is frozen in `spec/baselines/v0.1-alpha.md`.

## V0.2 (Memory Integrity)

Structural and provenance validation, negative tests, idempotence checks, and GitHub CI. Completed changes must leave the active area; broken routes and unresolvable evidence commits fail early.

## V0.3 (Project Profiles)

Init-time profiles (`template/profiles/software|paper/`) seed domain-appropriate knowledge and a declarative `.ai/profile.md` manifest; `validate.sh` checks the manifest-declared required knowledge set and falls back to the frozen software defaults when no manifest exists. Profile selection is explicit; detection may only suggest. Specified in `spec/v0.3-profiles.md`.

## V0.4 (Provenance Closeout)

The optional `scripts/close-provenance.sh` helper binds unresolved `verified_at_commit` placeholders in current memory to an existing full `HEAD` SHA. `checkpoint.sh` invokes it for initialized projects; it is idempotent, preserves existing provenance, and never edits semantic content or creates commits. Specified in `spec/v0.4-provenance-close.md`.

## Possible later versions

- optional generated FTS5/BM25 retrieval index
- dependency-aware task graph
- agent adapters that remain clients of canonical files
- richer link and stale-reference checks
- optional MCP or cloud integrations
- additional profiles (data-engineering, hardware/firmware) contributed as new `template/profiles/` directories

These must preserve the canonical repository format and remain opt-in.
