---
name: paper
required_knowledge: PROJECT.md RESEARCH_QUESTIONS.md METHODS.md EXPERIMENTS.md
---
# Profile: paper

APMF profile for research/paper projects where ideas and experiment records are the primary durable truth. Knowledge seeds: `PROJECT.md` (paper goal, venue, claims), `RESEARCH_QUESTIONS.md`, `METHODS.md`, `EXPERIMENTS.md` (experiment ledger with data versions, seeds, and environment commits), `ENVIRONMENT.md` (compute/toolchain; seeded but not required).

Use one active change per experiment or paper section milestone; record results and reproduction commands in its `evidence.md`. `init.sh` installs this file as `.ai/profile.md`; `validate.sh` then requires every `required_knowledge` entry to exist in `.ai/knowledge/`.
