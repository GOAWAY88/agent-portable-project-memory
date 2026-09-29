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
- hardened profile integrity: `init.sh` rejects invalid profile names and incomplete profile directories, checks every copy, applies the overlay all-or-nothing with conflict preflight, and never reports a profile as applied when it was not
- hardened `validate.sh` to reject `required_knowledge` entries that are not plain `.md` filenames, blocking `../` traversal, absolute paths, and nested paths
- renamed the project abbreviation from APPM to **APMF** across specs, docs, templates, scripts, and tests; `init.sh` still recognizes the legacy `.gitignore` marker so already-initialized projects stay idempotent (see `ADR-0001-apmf-abbreviation`)
- added `ABOUT.md`, emoji section headings in the README, and the first recorded ADR
- renamed the GitHub Actions workflow display name to `APMF CI`; the first rename audit was extension-filtered and missed it, and the omission is recorded as an explicit correction in `ADR-0001-apmf-abbreviation`
