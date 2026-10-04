# Architecture

APMF separates durable repository memory from an agent's temporary context. The layers are intentionally asymmetric: storage may grow, but default startup remains small.

| Layer | Canonical locations | Startup behavior |
|---|---|---|
| L0 bootstrap/routing | `AGENTS.md`, `.ai/NOW.md`, `.ai/INDEX.md` | Read first; keep small |
| L1 active work | `.ai/changes/<name>/` | Read only relevant active change |
| L2 current truth | `.ai/knowledge/`, `.ai/decisions/` | Retrieve by task |
| L3 historical | `.ai/archive/` | Never load by default |
| L4 retrieval | filesystem and INDEX in V0.1 | Optional derived SQLite FTS5/BM25 index in V0.6; rebuildable |

The canonical source is Git-tracked Markdown. The V0.6 FTS5/BM25 index accelerates retrieval but never replaces or mutates canonical truth. Projects may add files, but should not turn `NOW.md` into a database or append every session to one global log.

Memory is branch-aware. A claim should identify its branch/commit when that affects its validity; agents verify high-impact claims against `git status`, branch, recent commits, source, and tests.
