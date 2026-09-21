---
id: KNOW-ARCHITECTURE
status: current
updated: 2026-09-21
related:
  - spec/v0.1.md
  - docs/architecture.md
---
# Architecture

L0 routes through `AGENTS.md`, `.ai/NOW.md`, and `.ai/INDEX.md`; L1 stores active changes; L2 stores knowledge and ADRs; L3 archives history; L4 is a future derived retrieval layer. The root `.ai/` dogfoods the framework, while `template/.ai/` is what an initialized project receives.
