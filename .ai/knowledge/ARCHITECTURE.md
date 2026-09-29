---
id: KNOW-ARCHITECTURE
status: current
updated: 2026-09-24
verified_at_commit: 3c2a31f26754f164312e2deafa5e030a01d3c016
related:
  - spec/v0.1.md
  - docs/architecture.md
---
# Architecture

L0 routes through `AGENTS.md`, `.ai/NOW.md`, and `.ai/INDEX.md`; L1 stores active changes; L2 stores knowledge and ADRs; L3 archives history; L4 is a future derived retrieval layer. V0.2 validates the boundaries and provenance of L0–L3 before adding L4. The root `.ai/` dogfoods the framework, while `template/.ai/` is what an initialized project receives.
