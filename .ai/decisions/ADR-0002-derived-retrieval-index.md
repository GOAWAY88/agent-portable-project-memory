---
id: ADR-0002-derived-retrieval-index
status: accepted
created: 2026-10-04
updated: 2026-10-04
verified_at_commit: unknown
supersedes: null
superseded_by: null
evidence: .ai/changes/retrieval-index-v0.6/evidence.md
---
# ADR-0002-derived-retrieval-index: Keep FTS5/BM25 strictly derived

## Context

APMF's canonical project memory is human-readable Markdown tracked in Git. V0.1 through V0.5 now provide routing, integrity checks, provenance closeout, and lifecycle archival. A retrieval accelerator is useful, but a database that can silently become stale would undermine those guarantees.

## Decision

The optional V0.6 retrieval layer uses a disposable SQLite FTS5/BM25 database rebuilt from canonical `.ai/**/*.md` files. The database is ignored by Git, never treated as authoritative, and never used to write Markdown. Full rebuilds are preferred over incremental updates so deletions and renames cannot remain silently indexed. MCP, embeddings, vector stores, and agent adapters remain out of scope.

## Consequences

- Agents can search larger memory trees locally without changing the portable Markdown protocol.
- Rebuilding after a canonical edit is explicit and easy to verify; a corrupt index can simply be deleted.
- Retrieval has an optional Python/SQLite FTS5 dependency, while initialization, validation, and handoff remain dependency-free.

## Alternatives considered

- **Make the database canonical:** rejected because binary state is difficult to review and can diverge from Git-tracked Markdown.
- **Incremental index maintenance:** rejected because missed deletes and partial failures create stale-memory risk.
- **Introduce semantic retrieval or MCP:** rejected until the lexical derived layer has been exercised on real projects.

## Evidence and provenance

See `.ai/changes/retrieval-index-v0.6/evidence.md` and the V0.6 retrieval tests.
