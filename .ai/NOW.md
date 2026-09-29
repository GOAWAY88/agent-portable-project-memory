---
updated: 2026-09-29
branch: experiment/qwen-handoff
baseline_commit: 3c2a31f26754f164312e2deafa5e030a01d3c016
verified_at_commit: 5431ff3d7d8a07802e391c6d9ca3d8723d05715e
---
# Now

Project: **Agent-Portable Project Memory Framework**
Milestone: **V0.3 project profiles in progress**
Active change: **profile-templates-v0.3**
Current task: **Implement init-time project profiles (software default, paper overlay) with a declarative `.ai/profile.md` manifest driving `validate.sh` required-knowledge checks.**
Blockers: **none known**
Next action: **Restructure `template/` into shared core + `profiles/software|paper`, extend `init.sh --profile`, make `validate.sh` manifest-driven with software fallback, add tests and `spec/v0.3-profiles.md`, run the full suite, then merge to `main` after CI is green.**
Last verified state: **V0.1-alpha baseline is commit `3c2a31f26754f164312e2deafa5e030a01d3c016`; GitHub CI runs 36513243993, 36515061871, and 36515289887 passed on ubuntu-latest and macos-latest through commit `5431ff3d7d8a07802e391c6d9ca3d8723d05715e`.**

Relevant pointers: `.ai/INDEX.md`, `.ai/changes/profile-templates-v0.3/`, `docs/roadmap.md`, `spec/baselines/v0.1-alpha.md`.
