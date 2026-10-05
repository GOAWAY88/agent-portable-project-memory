---
id: handoff-gate-v0.8-proposal
status: draft
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: unknown
---
# Proposal: Unified handoff health gate

## Problem

APMF now has independent validators for structure, provenance, current references, lifecycle, and optional retrieval. A maintainer still has to remember which commands to run and how to interpret optional conditions before handing a project to another agent.

## Motivation

Provide one read-only health command that composes existing guarantees without making derived infrastructure authoritative. A complete end-to-end fixture should prove the helpers work together, not only in isolated tests.

## Scope

- Add `scripts/doctor.sh [--strict] <project>` as a read-only handoff gate.
- Compose structural validation, reference checks, provenance checks, Git state, NOW branch/blocker state, active-task summary, and optional retrieval-index freshness.
- Make `checkpoint.sh` run the doctor after provenance closeout.
- Add an end-to-end test covering init, first commit, provenance, active change, checkpoint, archive, retrieval, and final handoff.
- Dogfood the gate on `my-software-project`.

## Non-goals

- No semantic editing or automatic task completion.
- No requirement that optional retrieval dependencies or indexes exist.
- No remote CI/API checks inside the local doctor.

## Success criteria

- Healthy projects return zero with an explicit summary.
- Structural, reference, or provenance failures return non-zero.
- Warnings are non-fatal by default and fatal with `--strict`.
- The gate does not modify project files.
- The full lifecycle fixture passes on Ubuntu/macOS-compatible Bash.
