# Proposal: provenance-close-v0.4

## Problem

APMF templates correctly start with `verified_at_commit: unknown`, but a new project can make its first real commit and still carry unresolved provenance. The user then has to remember which memory files to edit after that commit.

## Motivation

Commit binding is mechanical, deterministic metadata. Closing it through the normal checkpoint path removes repetitive work without pretending that scripts can verify the truth of the underlying claims.

## Scope

- Add an idempotent `close-provenance.sh` helper with a no-write `--check` mode.
- Invoke it from `checkpoint.sh` for initialized APMF projects.
- Add cross-platform shell tests for unborn repositories, first-commit closeout, idempotence, check mode, and preservation of existing SHAs.
- Document the V0.4 contract and update the roadmap, command index, and handoff instructions.
- Archive the completed automatic-memory-maintenance change before activating this one.

## Non-goals

No automatic semantic editing, evidence fabrication, `updated` date rewriting, archive rewriting, commit creation, or agent/vendor-specific integration. Existing valid provenance is never rebased to HEAD.

## Success criteria

After a first commit, one checkpoint or explicit helper invocation replaces supported provenance placeholders with that commit's full SHA; an unborn repository remains unchanged; repeated runs are no-ops; `--check` detects unresolved placeholders; the full suite passes on Ubuntu and macOS.
