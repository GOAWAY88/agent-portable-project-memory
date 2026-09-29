# Design: apmf-rename-followup

## Approach

Two edits and a corrected audit method.

**Workflow name.** `.github/workflows/ci.yml` line 1 becomes `name: APMF CI`. The README badge points at `actions/workflows/ci.yml/badge.svg`, which resolves by *filename*, so changing the display name does not break the badge and no README edit is needed. Renaming the file itself was rejected: it would break the badge URL and every existing Actions history link for no benefit.

**Audit method.** The original audit filtered by extension, which is how YAML was missed. The replacement uses `git grep -n "APPM"` with no path filter, so it covers every tracked file regardless of type, and excludes `.ai/archive/` only when interpreting results — not when searching. Searching broadly and filtering during interpretation is the safer order; filtering first is what produced the miss.

**ADR correction.** `ADR-0001` is `accepted` and current, so its evidence section should be accurate. The correction is additive and explicit: it records that the original audit was extension-filtered, names `.github/workflows/ci.yml` as the file it missed, and states that the follow-up change fixed it. The original sentence is not silently deleted, because `docs/memory-lifecycle.md` requires superseded claims to be marked rather than rewritten, and an invisible correction would hide the fact that an audit claim was once wrong.

## Tradeoffs

Leaving a visible correction in an accepted ADR is slightly untidy compared with quietly fixing the sentence, but it preserves the audit trail and models the behavior the framework asks for: when a claim turns out to be wrong, mark it and point at the replacement. Appending a note to the archived change's evidence is a smaller version of the same choice — archives are historical, so the note is added as a dated correction rather than an edit to the original row.

## Risks

- Changing `name:` in a workflow file alters the display name shown in the Actions UI and in commit status contexts. Existing runs keep their recorded names; only new runs show `APMF CI`. No job, step, or trigger changes, so CI behavior is identical. Verified by running the full suite locally and confirming CI passes after the push.
- `git grep` searches tracked files only. An untracked file containing the old abbreviation would be missed, but untracked files are not part of the repository and cannot mislead a reader of it. `git status` is checked to confirm the tree is clean.
- The corrected audit may surface further occurrences that the extension filter hid. That is the point of re-running it; any new hit is handled in this change rather than deferred.

## Rejected alternatives

- **Renaming `ci.yml` to `apmf-ci.yml`:** breaks the README badge URL and all historical Actions links, for a cosmetic gain.
- **Silently editing the ADR sentence:** hides that an audit claim was wrong, which is exactly the failure mode the provenance rules exist to prevent.
- **Leaving the workflow name as-is:** the Actions page is the most visible surface of the project after the README; leaving the retired abbreviation there contradicts the rename decision.
- **Re-running the audit with more extensions (`--include="*.yml"`):** repeats the original mistake in a new form. An allowlist of extensions will always miss the next file type; `git grep` over all tracked files cannot.
