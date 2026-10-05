---
id: reference-integrity-v0.7-proposal
status: draft
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: unknown
---
# Proposal: Detect stale memory references

## Problem

APMF validates that `INDEX.md` paths exist, but other current-memory routes can become stale after a change is archived or renamed. In particular, an ADR can retain an evidence path under `.ai/changes/` after that directory has moved to `.ai/archive/changes/`, and NOW/knowledge/decision Markdown can retain dead local routes without an early diagnostic.

## Motivation

Make reference integrity explicit before adding more retrieval or task-graph features. A derived index must not make a broken canonical route harder to notice.

## Scope

- Validate ADR `evidence` front-matter as a local existing path when it names one.
- Add a focused checker for local paths in current `.ai/` Markdown, excluding historical archives and instructional templates.
- Detect missing paths and distinguish stale `.ai/changes/<name>/` references whose destination is already archived.
- Add negative tests for broken links, stale archived routes, valid archive paths, and safe external links.
- Run the checker in GitHub CI and document the boundary.

## Non-goals

- No automatic rewriting of arbitrary Markdown references.
- No recursive validation of `.ai/archive/` historical text.
- No URL availability checks, link crawling, or semantic reference resolution.

## Success criteria

- Current memory fails clearly when a local route is missing or still points at an archived active change.
- Valid paths, placeholders in instructional templates, and external URLs are not false positives.
- Existing V0.1–V0.6 tests and canonical workflows remain compatible.
