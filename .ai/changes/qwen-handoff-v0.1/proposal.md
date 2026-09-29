# Proposal: qwen-handoff-v0.1

## Problem

After commit `002c9d6` archived the only completed change, `.ai/changes/` became empty. Git does not track empty directories, so the directory disappears in fresh clones and worktrees. `scripts/validate.sh` requires `.ai/changes` to exist, and `tests/test_v01_baseline.sh` checks the same path, so CI on `main` fails at the "Validate framework memory" step (GitHub Actions run 36509132904, both ubuntu-latest and macos-latest).

## Motivation

A repository that validates itself must remain valid in its canonical state with zero active changes. Otherwise every post-archival commit breaks CI and the framework fails its own dogfooding contract.

## Scope

- Add a tracked placeholder `.ai/changes/README.md` following the existing convention of `.ai/decisions/README.md` and `.ai/archive/README.md`.
- Add a regression check to `tests/test_v01_structure.sh` asserting that at least one file under `.ai/changes/` is Git-tracked.
- Record the handoff context reconstruction and this fix in change artifacts and evidence.

## Non-goals

No changes to `validate.sh` rules, no new spec requirements, no retrieval layer, no CI workflow changes beyond what the fix makes pass again.

## Success criteria

`bash -n scripts/*.sh tests/*.sh`, `./scripts/validate.sh .`, `./tests/test_v01_baseline.sh`, `./tests/test_v01_structure.sh`, and `./tests/test_memory_integrity.sh` all pass on the working tree at branch `experiment/qwen-handoff`, and the state is reproducible from a fresh clone because the placeholder is tracked.
