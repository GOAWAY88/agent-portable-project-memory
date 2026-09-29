---
updated: 2026-09-29
branch: docs/apmf-rename-and-about
baseline_commit: 3c2a31f26754f164312e2deafa5e030a01d3c016
verified_at_commit: 85380f55d8265480aa74f037bb224915de0b8807
---
# Now

Project: **Agent-Portable Project Memory Framework**
Milestone: **V0.3 hardened; APMF rename and ABOUT document in progress**
Active change: **apmf-rename-and-about**
Current task: **Rename the project abbreviation from APPM to APMF across specs, docs, templates, scripts, and tests; add emoji to README headings; write a narrative `ABOUT.md`; record the rename as `ADR-0001`.**
Blockers: **none known**
Next action: **Commit on `docs/apmf-rename-and-about`, push, confirm GitHub CI is green on Ubuntu and macOS, then fast-forward merge to `main` and archive the change.**
Last verified state: **V0.1-alpha baseline is commit `3c2a31f26754f164312e2deafa5e030a01d3c016`; branch created from `main` at `85380f55d8265480aa74f037bb224915de0b8807`, which passed GitHub CI run 36537873993 on ubuntu-latest and macos-latest; the rename, legacy-marker compatibility test, emoji README, `ABOUT.md`, and `ADR-0001` are implemented and the full local suite (syntax, validate, baseline, structure, integrity, whitespace) passes; residual abbreviation audit shows hits only in the intentional legacy-marker path.**

Relevant pointers: `.ai/INDEX.md`, `.ai/changes/apmf-rename-and-about/`, `spec/v0.3-profiles.md`, `scripts/init.sh`, `tests/test_v01_baseline.sh`.
