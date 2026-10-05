---
id: handoff-gate-v0.8-ci-fix-design
status: draft
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: unknown
---
# Design: Capability-aware handoff fixture

## Approach

The test calls `index-memory.sh --check` first. If Python/SQLite FTS5 is available, it rebuilds the index and requires strict doctor success. If not, it records an explicit pass for optional unavailability and uses default doctor for the final end-to-end assertion; strict mode remains tested as rejecting an absent index.

## Tradeoffs

The macOS job may not exercise BM25 in environments without Python/FTS5, but V0.6 has its own capability-aware retrieval test and the canonical handoff path remains fully tested.

## Risks

A future runner could make the capability probe pass while retrieval itself fails; the subsequent rebuild and strict doctor assertions catch that mismatch.

## Rejected alternatives

- Installing Python/SQLite in CI was rejected because retrieval is optional and the framework's baseline has no runtime dependency.
- Removing strict assertions was rejected because strict mode is the release gate when optional retrieval is available.
