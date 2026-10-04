---
id: retrieval-index-v0.6-proposal
status: draft
created: 2026-10-04
updated: 2026-10-04
verified_at_commit: unknown
---
# Proposal: Rebuildable FTS5/BM25 retrieval index

## Problem

APMF's canonical Markdown is now structurally validated and its change lifecycle is mechanically closed. Retrieval still requires walking `INDEX.md` and opening files one by one, which is reliable but slow when a project has accumulated many knowledge, decision, active-change, and archive documents.

## Motivation

Add an optional, local retrieval accelerator without changing the protocol's source of truth. The index must be disposable, deterministic enough to rebuild, and safe to ignore in Git.

## Scope

- Add a helper that rebuilds `.ai/index/memory.sqlite3` from canonical `.ai/**/*.md` files.
- Add FTS5 search with BM25 ranking and bounded snippets.
- Add read-only preflight and query modes.
- Cover rebuild, stale-document removal, idempotence, and canonical-file preservation with tests.
- Document Python standard-library SQLite/FTS5 as an optional dependency; the Markdown workflow remains dependency-free.

## Non-goals

- No embeddings, vector database, MCP server, cloud service, or agent-specific adapter.
- No mutation of canonical Markdown from the index helper.
- No committed database or requirement that every target project install the optional dependency.

## Success criteria

- A fresh index can be rebuilt from `.ai/**/*.md` and queried with BM25 ranking.
- Removing or changing a canonical document removes stale content after the next rebuild.
- Rebuilds are atomic: a failed build does not replace the previous index.
- Existing V0.1–V0.5 tests and validation remain green on Ubuntu/macOS-compatible Bash.
