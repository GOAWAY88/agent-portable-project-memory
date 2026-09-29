# Changelog

## V0.1 - 2026-09-21

- established layered, repository-owned memory model
- added versioned specification, schemas, lifecycle and authority rules
- added portable `.ai/` template and safe initializer
- added context, checkpoint, validation scripts and structural tests
- added dogfood memory for this framework repository

## V0.2 - 2026-09-24

- strengthened validation for links, statuses, provenance, evidence, and completed changes
- added negative integrity/idempotence tests and Linux/macOS GitHub CI
- froze the V0.1-alpha compatibility baseline
- explicitly deferred SQLite/FTS5/BM25, MCP, semantic retrieval, and adapters

## V0.3 - 2026-09-29

- added init-time project profiles (`software` default, `paper` overlay) seeded from `template/profiles/`
- made `validate.sh` enforce the declarative `.ai/profile.md` required-knowledge manifest, with frozen software defaults as fallback
- preserved the empty canonical `.ai/changes/` directory after active changes are archived
