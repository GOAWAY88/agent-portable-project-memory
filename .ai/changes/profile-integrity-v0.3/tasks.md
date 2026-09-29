# Tasks: profile-integrity-v0.3

- [x] `DONE` Reproduce all three integrity failures on `main` at `816395b` and record them as evidence
- [x] `DONE` Fix 1: reject illegal `--profile` names and incomplete profile directories in `init.sh`
- [x] `DONE` Fix 1b: check every `cp` exit status and emit `profile applied` only after full success
- [x] `DONE` Fix 2: enforce plain `.md` filenames in `required_knowledge` without glob expansion in `validate.sh`
- [x] `DONE` Fix 3: preflight profile overlay conflicts before any write; exit non-zero with no partial state
- [x] `DONE` Add the twelve required negative tests using temporary Git repos and a temporary framework copy
- [x] `DONE` Update `spec/v0.3-profiles.md`, README, and CHANGELOG for the tightened behavior
- [x] `DONE` Run the full validation suite plus `git status` / `git diff --stat` and record results in evidence.md
- [ ] `TODO` Update `.ai/NOW.md`, then push and confirm GitHub CI before archiving
