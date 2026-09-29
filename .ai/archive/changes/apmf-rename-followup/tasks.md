# Tasks: apmf-rename-followup

Note: the validator reads every backticked ALL-CAPS token in this file as a task
status, so abbreviations are written without backticks here.

- [x] `DONE` Re-run the residual audit with git grep over all tracked files and record the result
- [x] `DONE` Rename the CI workflow display name to APMF CI
- [x] `DONE` Correct the residual-audit claim in ADR-0001 as an explicit, dated correction
- [x] `DONE` Append a correction note to the archived apmf-rename-and-about evidence
- [x] `DONE` Update CHANGELOG and .ai/NOW.md
- [x] `DONE` Run the full validation suite and record evidence
- [x] `DONE` Push `fix/apmf-ci-name` and confirm GitHub CI green (run 36543893144)
- [x] `DONE` Fast-forward merge to `main` (`c866bd4..d057306`), confirm CI green there (run 36544185004), and archive this change
