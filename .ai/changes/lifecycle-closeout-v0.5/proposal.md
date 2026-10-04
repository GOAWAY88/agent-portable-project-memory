# Proposal: lifecycle-closeout-v0.5

## Problem

Dogfooding found that manually moving a completed change into `.ai/archive/changes/` can leave `NOW.md`, `INDEX.md`, or ADR evidence paths pointing at the removed active directory. The repository then contains a false bootstrap route and fails validation.

## Motivation

Archival is a repeatable lifecycle operation. A mechanical helper can enforce the structural invariants without inventing semantic summaries or creating commits on the user's behalf.

## Scope

- Add `scripts/archive-change.sh [--check] <project> <change>`.
- Preflight active-route identity, four artifacts, all-DONE task status, destination conflicts, and INDEX/ADR references.
- Move the change atomically with rollback on route-update or validation failure.
- Set NOW to no active change, route INDEX current work to NOW, and move exact ADR evidence references to the archive.
- Add cross-platform lifecycle tests, CI coverage, V0.5 specification, and documentation.

## Non-goals

No Git commit creation, semantic summary generation, rewriting of archived files, automatic changes to `updated` or provenance fields, or inference of whether a task is substantively complete.

## Success criteria

A completed active change can be archived in one checked operation; stale routes fail preflight; incomplete changes, destination conflicts, and repeated archive attempts fail without writes; successful archives validate; `--check` is read-only; and the full suite passes on Ubuntu and macOS.
