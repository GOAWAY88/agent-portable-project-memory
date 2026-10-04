---
id: retrieval-index-v0.6-design
status: draft
created: 2026-10-04
updated: 2026-10-04
verified_at_commit: unknown
---
# Design: Rebuildable FTS5/BM25 retrieval index

## Approach

`scripts/index-memory.sh` is a thin Bash entry point around Python's standard-library `sqlite3` module. The helper discovers UTF-8 Markdown files beneath `.ai/`, excluding `.ai/index/`, sorts paths, and builds a temporary SQLite database in the destination directory before an atomic replacement.

The database contains a `metadata` table and an FTS5 `documents` virtual table. Each row stores a repository-relative path and Markdown content. Search uses parameterized FTS5 `MATCH`, `bm25()`, and `snippet()` expressions; output is tab-separated for simple agent and shell consumption.

## Tradeoffs

- Python's standard library avoids depending on the platform's `sqlite3` CLI syntax, while Python remains an optional dependency only for retrieval.
- The index stores complete Markdown content for simple snippets and deterministic rebuilds; ignored local storage keeps it out of commits.
- Archived Markdown is indexed because it can answer historical questions, but agents still start from `NOW.md` and `INDEX.md` rather than the database.

## Risks

- A Python build without FTS5 cannot provide search; `--check` reports this explicitly and the canonical workflow continues to work.
- FTS5 query syntax is user-facing; malformed queries fail without changing the database.
- SQLite files are derived artifacts and may become stale; every supported write path is a full rebuild, never an incremental truth update.

## Rejected alternatives

- **Vector embeddings or MCP now:** rejected because they add agent/provider coupling before the canonical retrieval contract has been exercised.
- **A committed database:** rejected because binary state is not review-friendly and can diverge from Markdown.
- **Incremental indexing:** rejected because missed deletes or partial updates would create silent stale-memory failures; full rebuild is easier to verify.
