---
id: KNOW-ARCHITECTURE
status: current
updated: 2026-09-29
verified_at_commit: 5431ff3d7d8a07802e391c6d9ca3d8723d05715e
related:
  - spec/v0.1.md
  - spec/v0.3-profiles.md
  - docs/architecture.md
---
# Architecture

L0 routes through `AGENTS.md`, `.ai/NOW.md`, and `.ai/INDEX.md`; L1 stores active changes; L2 stores knowledge and ADRs; L3 archives history; L4 is a future derived retrieval layer. V0.2 validates the boundaries and provenance of L0–L3 before adding L4. V0.3 adds init-time profiles: `template/.ai/` is the shared core, `template/profiles/<name>/` overlays knowledge seeds, an INDEX router, and a `.ai/profile.md` manifest that declares the required knowledge set for `validate.sh`. The root `.ai/` dogfoods the framework (software profile), while `template/` is what an initialized project receives.
