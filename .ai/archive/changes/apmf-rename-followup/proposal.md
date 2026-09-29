# Proposal: apmf-rename-followup

## Problem

The `apmf-rename-and-about` change renamed the project abbreviation to APMF, but its residual audit used `grep -rn "APPM" --include="*.md" --include="*.sh"`, which excluded YAML. As a result `.github/workflows/ci.yml` still declares `name: APPM CI`, so the GitHub Actions workflow is displayed under the retired abbreviation while every other current file says APMF.

The audit claim recorded in `ADR-0001-apmf-abbreviation` ("Post-change residual audit … shows hits only in the intentional legacy-marker compatibility path, its test, and the change/NOW records") is therefore factually wrong, and `ADR-0001` is an `accepted`, current decision record — not archived history — so leaving an inaccurate audit claim in it undermines the provenance the framework exists to protect.

## Motivation

A rename that misses a user-visible surface is worse than no rename, because readers now see two names and cannot tell which is current. And an ADR whose evidence section overstates what was verified teaches the next agent to trust audit claims without re-checking them.

## Scope

- Rename the CI workflow display name from `APPM CI` to `APMF CI` in `.github/workflows/ci.yml`.
- Correct the residual-audit claim in `ADR-0001-apmf-abbreviation` to state what was actually searched, name the missed file, and record that it is now fixed — as an explicit correction, not a silent rewrite.
- Re-run the audit across **all** tracked file types, not just Markdown and shell, and record the command used.
- Note the lesson in the archived change's evidence so the incomplete-audit mistake is discoverable.

## Non-goals

No change to CI triggers, jobs, steps, or the matrix. No change to the README badge, which already references the workflow by filename (`actions/workflows/ci.yml`) rather than by display name and is therefore unaffected. No reopening or rewriting of the archived `apmf-rename-and-about` change artifacts other than appending a correction note to its evidence. No new abbreviation, no further renaming.

## Success criteria

`git grep -n "APPM"` over all tracked files returns hits only in `.ai/archive/`, in the intentional legacy-marker compatibility path in `scripts/init.sh` and its test, and in text that describes the rename itself (ADR, CHANGELOG, evidence). The workflow displays as `APMF CI`. The full suite (`bash -n`, `validate.sh`, baseline, structure, integrity, `git diff --check`) passes locally, and GitHub CI passes on Ubuntu and macOS after the rename.
