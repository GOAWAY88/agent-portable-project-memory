# Roadmap

## V0.1 (frozen alpha baseline)

Portable Markdown, layered routing, active changes, provenance, authority/staleness rules, archives, and minimal POSIX-friendly helpers. The compatibility contract is frozen in `spec/baselines/v0.1-alpha.md`.

## V0.2 (Memory Integrity)

Structural and provenance validation, negative tests, idempotence checks, and GitHub CI. Completed changes must leave the active area; broken routes and unresolvable evidence commits fail early.

## Possible later versions

- optional generated FTS5/BM25 retrieval index
- dependency-aware task graph
- agent adapters that remain clients of canonical files
- richer link and stale-reference checks
- optional MCP or cloud integrations

These must preserve the canonical repository format and remain opt-in.
