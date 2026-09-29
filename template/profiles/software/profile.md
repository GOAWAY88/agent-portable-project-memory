---
name: software
required_knowledge: PROJECT.md ARCHITECTURE.md COMMANDS.md
---
# Profile: software

Default APMF profile for software projects. Durable knowledge seeds: `PROJECT.md` (purpose/scope), `ARCHITECTURE.md` (components and boundaries), `COMMANDS.md` (verified build/test commands), `ENVIRONMENT.md` (toolchain and constraints; seeded but not required).

`init.sh` installs this file as `.ai/profile.md`; `validate.sh` then requires every `required_knowledge` entry to exist in `.ai/knowledge/`. Edit the list as the project's durable-knowledge needs evolve, one manifest per project.
