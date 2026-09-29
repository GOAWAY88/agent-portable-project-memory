# Proposal: apmf-rename-and-about

## Problem

The project has been abbreviated **APPM** (Agent-Portable Project Memory) across specs, scripts, templates, tests, and docs. The maintainer now wants **APMF** (Agent-Portable Project Memory **Framework**) as the single canonical abbreviation, because the artifact is a framework/protocol, not just the memory itself. Separately, the README is dense and text-only, and the repository has no narrative "about" document explaining why the project exists, who it is for, and how it differs from agent-vendor memory features.

Two concrete hazards make this more than a find-and-replace:

- `scripts/init.sh` writes the literal marker `# APPM derived/local memory infrastructure` into a target project's `.gitignore` and later greps for that exact string to stay idempotent. Renaming the marker alone would make every already-initialized project fail the check and get a **second, duplicate** ignore block on the next run.
- `tests/test_v01_baseline.sh` greps `README.md` for three frozen phrases (`repository owns project memory`, `V0.1`, `not an LLM memory database`). Any README rewrite that drops one of them turns CI red.

## Motivation

A single unambiguous name prevents drift between normative spec text and user-facing docs. An ABOUT document gives a new reader — human or agent — the project's purpose and boundaries in one place, which is exactly the kind of durable knowledge this framework says should live in the repository rather than in chat history.

## Scope

- Rename `APPM` → `APMF` in all non-archived files: `spec/v0.1.md`, `spec/v0.2-memory-integrity.md`, `spec/v0.3-profiles.md`, `docs/architecture.md`, `scripts/init.sh`, `scripts/validate.sh`, `tests/test_v01_structure.sh`, `template/AGENTS.md`, `template/profiles/*/profile.md`.
- Make the `.gitignore` idempotence marker accept **both** the new `# APMF …` and the legacy `# APPM …` marker, so previously initialized projects stay idempotent; newly initialized projects get the APMF marker.
- Update `tests/test_v01_structure.sh` for the renamed marker and add a legacy-marker compatibility check.
- Add tasteful emoji to README section headings while preserving all three frozen baseline phrases verbatim.
- Add `ABOUT.md` (origin, problem, design philosophy, who it is for, how it differs from vendor memory, non-goals) and link it from README and `.ai/INDEX.md`.
- Record the rename as `ADR-0001` with evidence, and update `.ai/NOW.md` plus `CHANGELOG.md`.

## Non-goals

No change to the frozen `spec/baselines/v0.1-alpha.md` contract (it contains no `APPM` string, verified). No behavioral change to validation rules, profiles, or the change lifecycle. No rewrite of archived material under `.ai/archive/` — archives are historical records and must not be silently rewritten. No new runtime dependency, database, MCP server, or retrieval layer. No rename of the repository, directory, or Git remote.

## Success criteria

`grep -rn "APPM"` returns hits only under `.ai/archive/` and in the legacy-marker compatibility path; the full suite (`bash -n`, `validate.sh`, baseline, structure, integrity, `git diff --check`) passes locally and in GitHub CI on Ubuntu and macOS; re-running `init.sh` on a project whose `.gitignore` carries the legacy `# APPM` marker does not duplicate the block; README still contains all three frozen phrases; `ABOUT.md` exists and is routed from README and `.ai/INDEX.md`; `ADR-0001` is `accepted` with non-empty evidence.
