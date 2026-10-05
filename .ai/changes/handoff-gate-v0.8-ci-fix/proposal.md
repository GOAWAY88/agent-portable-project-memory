---
id: handoff-gate-v0.8-ci-fix-proposal
status: draft
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: unknown
---
# Proposal: Make handoff-gate CI dependency-aware

## Problem

The first V0.8 CI run passed on Ubuntu but failed on macOS in `test_handoff_gate.sh`. The end-to-end test assumed Python/SQLite FTS5 was available even though V0.6 retrieval is explicitly optional.

## Motivation

Keep the handoff gate strict about canonical memory while making optional retrieval behavior honest across runners that do not ship Python or FTS5.

## Scope

- Probe optional FTS5 support before requiring strict retrieval freshness in the handoff fixture.
- When unavailable, verify default doctor behavior and preserve the strict-mode diagnostic contract.
- Record the regression and rerun the full local suite.

## Non-goals

- No change to canonical memory validation.
- No weakening of strict mode when an index is present or when optional support is available.

## Success criteria

- Ubuntu and macOS can run the same test without assuming optional dependencies.
- The test still verifies strict current-index behavior when FTS5 is available.
- The default handoff gate remains usable without retrieval support.
