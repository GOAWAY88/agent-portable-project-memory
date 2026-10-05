# Evidence: handoff-gate-v0.8-ci-fix

| Date | Branch/SHA | Command or observation | Result |
|---|---|---|---|
| 2026-10-05 | main / 66f0e09 | CI run `37258901334` | Ubuntu passed; macOS failed only at `Run V0.8 handoff gate tests`, indicating the fixture assumed an optional retrieval dependency. |
| 2026-10-05 | main / working tree | `./tests/test_handoff_gate.sh`; Bash syntax; `git diff --check` | Capability-aware test passes locally with FTS5 available and preserves strict/default semantics. |
| 2026-10-05 | main / 652a75c | Full local suite: syntax, validate, references, V0.1 baseline/structure, memory integrity, lifecycle closeout, retrieval index, reference integrity, handoff gate | All checks passed after the portability fix. |
| 2026-10-05 | main / 8c1158f | Bash 3.2 compatibility run: `PATH=/tmp/bash32-build-20261005/install/bin:$PATH bash tests/test_handoff_gate.sh` | Reproduced `adr_files[@]: unbound variable` in `archive-change.sh`; fixed route-file assembly to append ADR paths without expanding an empty array. |
| 2026-10-05 | main / 8c1158f | Full Bash 3.2 suite: syntax, validate, references, V0.1 baseline/structure, memory integrity, lifecycle closeout, retrieval index, reference integrity, handoff gate | All checks passed with child scripts invoked through Bash 3.2. |
