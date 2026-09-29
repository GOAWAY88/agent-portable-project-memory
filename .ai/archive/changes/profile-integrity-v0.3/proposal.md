# Proposal: profile-integrity-v0.3

## Problem

V0.3 project profiles shipped with three integrity holes, all reproduced locally on `main` at `816395b`:

1. **`init.sh` accepts illegal profile names and reports false success.** `./scripts/init.sh --profile .. /tmp/project` resolves `PROFILE_DIR` to `template/profiles/..`, the `cp` calls for `INDEX.md` and `profile.md` fail with "No such file or directory", yet `copy_if_missing` never checks `cp`'s exit status — it prints `CREATED: .ai/INDEX.md` and `CREATED: .ai/profile.md` for files that do not exist, then prints `init: profile '..' applied` and exits 0. A project is left with no manifest and no INDEX while the operator is told everything succeeded.
2. **`validate.sh` accepts path traversal in `required_knowledge`.** A manifest containing `required_knowledge: ../../AGENTS.md` passes validation, because the only check is the `*.md` suffix glob. The required-knowledge contract can therefore be satisfied by a file outside `.ai/knowledge/`, defeating the manifest's purpose.
3. **Profile overlay conflicts are reported but still claim success.** Running `init.sh --profile paper` over an existing software project preserves the old `.ai/profile.md` and `.ai/INDEX.md` (correctly not overwriting), yet still prints `init: profile 'paper' applied` and exits 0. The resulting tree has `name: software` in the manifest while the command claimed paper was applied — exactly the mixed state V0.3 must not produce.

## Motivation

V0.2 established that validation is a guardrail against silent memory drift, and that a validator MUST fail loudly rather than accept malformed provenance. These three holes let `init.sh` and `validate.sh` report success while writing or accepting broken canonical memory. An agent that trusts that success signal will build on a project whose profile manifest is absent, wrong, or pointing outside the knowledge tree.

## Scope

- `scripts/init.sh`: validate `--profile` against `^[a-z][a-z0-9-]*$`; require `profile.md`, `INDEX.md`, and `knowledge/` to all exist in the profile directory; preflight the overlay for unacceptable conflicts before writing anything; check every `cp` exit status; print `init: profile '<name>' applied` only after all overlay files are successfully handled; exit non-zero on any copy failure or conflict.
- `scripts/validate.sh`: require every `required_knowledge` entry to be a plain `.md` filename matching `^[A-Za-z0-9][A-Za-z0-9._-]*\.md$` (no `/`, no traversal, no absolute path) and to exist in `.ai/knowledge/`; split the list without glob expansion.
- Negative tests in `tests/test_v01_structure.sh` covering all twelve required cases, using temporary Git repositories and a temporary copy of the framework tree so the real repository is never modified.
- Spec clarification in `spec/v0.3-profiles.md`, plus README/CHANGELOG notes where the behavior is user-visible.

## Non-goals

No database, MCP server, vector retrieval, or new runtime dependency. No changes to the four-artifact change model, status vocabularies, provenance rules, or the frozen V0.1-alpha baseline. No new profiles. No automatic project-type detection. No V0.4 features. Shared-core copy behavior (existing files preserved, exit 0) is unchanged, because `test_v01_structure.sh` freezes it as V0.1 idempotence behavior.

## Success criteria

All twelve required negative tests pass; `init.sh --profile ..`, `paper/..`, and `BadName` exit non-zero; a profile directory missing any of `profile.md`, `INDEX.md`, or `knowledge/` exits non-zero; manifests using `../../AGENTS.md`, `foo/bar.md`, or `file.txt` fail validation; an existing differing `.ai/profile.md` or `.ai/INDEX.md` produces a reported conflict and non-zero exit with no partial write; re-running the same profile is idempotent and exits 0. The full suite (`bash -n`, `validate.sh`, baseline, structure, integrity, `git diff --check`) passes locally and in GitHub CI on Ubuntu and macOS.
