# Tasks: apmf-rename-and-about

Note: the validator reads every backticked ALL-CAPS token in this file as a task
status, so the old and new abbreviations are written without backticks here.

- [x] `DONE` Rename the old APPM abbreviation to APMF across spec/, docs/, template/, scripts/, tests/
- [x] `DONE` Widen the init.sh gitignore marker check to accept the legacy APPM marker
- [x] `DONE` Update marker assertions in tests/test_v01_structure.sh and add a legacy-marker idempotence test
- [x] `DONE` Add emoji to README headings while preserving the three frozen baseline phrases
- [x] `DONE` Write ABOUT.md and link it from README and .ai/INDEX.md
- [x] `DONE` Record ADR-0001 for the rename and update .ai/decisions/README.md
- [x] `DONE` Update CHANGELOG.md and .ai/NOW.md
- [x] `DONE` Run the full suite plus a residual abbreviation audit and record evidence
- [ ] `TODO` Push, confirm GitHub CI green, then archive after merge
