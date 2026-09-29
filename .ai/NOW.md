---
updated: 2026-09-29
branch: fix/apmf-ci-name
baseline_commit: 3c2a31f26754f164312e2deafa5e030a01d3c016
verified_at_commit: 0a4f523be0ddab6fa4351b5db6e894f19c53c080
---
# Now

Project: **Agent-Portable Project Memory Framework**
Milestone: **V0.3 hardened; APMF rename follow-up in progress**
Active change: **apmf-rename-followup**
Current task: **The first rename audit was extension-filtered and missed `.github/workflows/ci.yml`, so the workflow still displayed as `APPM CI`. Rename it to `APMF CI` and correct the inaccurate audit claim recorded in `ADR-0001-apmf-abbreviation`.**
Blockers: **none known**
Next action: **Fast-forward merge `fix/apmf-ci-name` into `main`, confirm CI there, then archive `apmf-rename-followup`.**
Last verified state: **V0.1-alpha baseline is commit `3c2a31f26754f164312e2deafa5e030a01d3c016`; branch created from `main` at `c866bd4a506727b9e3714a2139b7660b0b6cdc97`; GitHub CI run 36543893144 passed on ubuntu-latest and macos-latest for commit `0a4f523be0ddab6fa4351b5db6e894f19c53c080`; `git grep -n "APPM"` over all tracked files confirms the workflow name was the only genuine miss, with every other hit being the intentional legacy-marker path, its test, or text describing the rename.**

Relevant pointers: `.ai/INDEX.md`, `.ai/changes/apmf-rename-followup/`, `.ai/decisions/ADR-0001-apmf-abbreviation.md`, `.github/workflows/ci.yml`.
