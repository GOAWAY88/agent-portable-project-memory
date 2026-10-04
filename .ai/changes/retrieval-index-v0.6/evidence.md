# Evidence: retrieval-index-v0.6

| Date | Branch/SHA | Command or observation | Result |
|---|---|---|---|
| 2026-10-04 | main / 78a5569 | Read `.ai/NOW.md`, `.ai/INDEX.md`, roadmap, architecture, CI, and ignore rules; verified Python 3.8.10 with SQLite 3.31.1 and FTS5 enabled in the local environment | The next bounded feature is an optional rebuildable FTS5/BM25 layer; canonical Markdown and existing no-database workflows remain unchanged. |
| 2026-10-05 | main / working tree | `./tests/test_retrieval_index.sh`; `./scripts/index-memory.sh --check .`; rebuild/query/stale-source fixture checks | Preflight, rebuild, BM25 query, query-idempotence, malformed-query rejection, unchanged failed-query database, deleted-source removal, and Git ignore behavior passed. |
| 2026-10-05 | my-software-project/main / 033295e | `./scripts/index-memory.sh --check /home/dary/my-software-project`; rebuild; `--query endpoint`; `./scripts/validate.sh /home/dary/my-software-project`; `git status --short --branch` | Real target dogfood indexed 33 Markdown documents, returned ranked canonical paths/snippets, passed validation, and left the target Git worktree clean; the derived database is ignored. |
