# Evidence: lifecycle-closeout-v0.5

| Date | Branch/SHA | Command or observation | Result |
|---|---|---|---|
| 2026-10-04 | main / 8d4e828 | Read `.ai/NOW.md`, `.ai/INDEX.md`, current handoff/validation scripts, and the dogfooded target's archived route repair | Confirmed the next framework change should mechanize completed-change archival; the target had failed validation before manual route repair. |
| 2026-10-04 | main / working tree | `bash -n scripts/*.sh tests/*.sh`; `./scripts/validate.sh .`; `./tests/test_v01_baseline.sh`; `./tests/test_v01_structure.sh`; `./tests/test_memory_integrity.sh`; `./tests/test_lifecycle_closeout.sh`; `git diff --check` | All passed. Lifecycle tests cover read-only preflight, successful route repair, repeated archive rejection, incomplete tasks, destination conflict, rollback after validation failure, and ADR evidence relocation. |
| 2026-10-04 | my-software-project/main / 299e3fd → 033295e | `/home/dary/agent-portable-project-memory/scripts/archive-change.sh --check . lifecycle-dogfood-v0.1`; archive helper; `/home/dary/agent-portable-project-memory/scripts/validate.sh .`; `close-provenance.sh`; clean Git status | Real target dogfood passed: preflight made no writes, completed change moved to archive, NOW/INDEX routes were repaired, validation passed, and provenance was closed in a follow-up commit. |
