# Evidence: reference-integrity-v0.7

| Date | Branch/SHA | Command or observation | Result |
|---|---|---|---|
| 2026-10-05 | main / e70dbbe | Reviewed `validate.sh`, current `.ai/` routes, archived change paths, and the V0.6 release state | Confirmed the next integrity boundary is stale current-memory references, especially ADR evidence paths after lifecycle archival. |
| 2026-10-05 | main / working tree | `./scripts/check-references.sh .`; `./scripts/validate.sh .`; `./tests/test_reference_integrity.sh`; full existing test suite | Framework checker, ADR evidence validation, stale-route negative fixtures, and all prior baseline/integrity/lifecycle/retrieval tests passed. |
| 2026-10-05 | my-software-project/main / 1d0f7a | Framework checker and validator before/after route repair; target `git diff --check`; archive helper | Dogfood found and repaired a stale NOW route and an ADR evidence route left behind by earlier archival; target change was archived and the worktree is clean. |
