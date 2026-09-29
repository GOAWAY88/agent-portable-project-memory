---
id: ADR-0001-apmf-abbreviation
status: accepted
created: 2026-09-29
updated: 2026-09-29
verified_at_commit: 85380f55d8265480aa74f037bb224915de0b8807
supersedes: null
superseded_by: null
evidence: .ai/archive/changes/apmf-rename-and-about/evidence.md
---
# ADR-0001-apmf-abbreviation: Use APMF as the canonical project abbreviation

## Context

The project's full name is Agent-Portable Project Memory Framework. Documentation and code abbreviated it inconsistently as **APPM** (Agent-Portable Project Memory), dropping the "Framework" that names what the artifact actually is: a protocol plus a template, not a memory store. The abbreviation appeared in normative spec text (`An APPM V0.1-compatible project MUST provide…`), in user-facing script output, in generated project templates, and in test assertions — so the drift was visible to every reader and to every initialized downstream project.

The maintainer asked for **APMF** to become the single canonical abbreviation.

Two properties of the codebase constrained the change:

- `scripts/init.sh` writes the literal marker `# APPM derived/local memory infrastructure` into a target project's `.gitignore` and later greps for that exact string to remain idempotent. Renaming the written marker alone would make every already-initialized project fail detection and receive a **second, duplicate** ignore block on the next run.
- `spec/baselines/v0.1-alpha.md` is a frozen compatibility contract. Verified by inspection: it contains no occurrence of the abbreviation, so the rename cannot weaken the baseline.

## Decision

Adopt **APMF** as the canonical abbreviation everywhere outside `.ai/archive/`, and treat the rename as a protocol-visible string change with a compatibility window rather than a cosmetic edit.

1. **Rename in place** across `spec/v0.1.md`, `spec/v0.2-memory-integrity.md`, `spec/v0.3-profiles.md`, `docs/architecture.md`, `scripts/init.sh`, `scripts/validate.sh`, `tests/test_v01_structure.sh`, `template/AGENTS.md`, and both `template/profiles/*/profile.md`.
2. **Write the new marker, detect both.** `init.sh` writes only `# APMF derived/local memory infrastructure`, but its idempotence check accepts either the new marker or the legacy `# APPM …` marker. A project initialized before the rename therefore stays idempotent and its `.gitignore` is left byte-identical.
3. **Do not migrate legacy markers in place.** Rewriting a user's `.gitignore` is a side effect beyond the initializer's contract, and the legacy marker is harmless once detection accepts it.
4. **Do not rewrite archives.** Files under `.ai/archive/` keep the abbreviation they used when written. `docs/memory-lifecycle.md` requires that superseded material be marked rather than silently rewritten, and archived changes are historical evidence of what the text said at the time.
5. **Pin the compatibility window with a test.** `tests/test_v01_structure.sh` gains a check that initializes a project, rewrites its marker back to the legacy form, re-runs `init.sh`, and asserts the block still appears exactly once and the file is unchanged.
6. **Preserve frozen README phrases.** `tests/test_v01_baseline.sh` greps `README.md` for `repository owns project memory`, `V0.1`, and `not an LLM memory database`; the concurrent README redesign keeps all three verbatim.

The repository name, directory name, and Git remote are **not** renamed; those are disruptive to existing clones and worktrees and were not requested.

## Consequences

**Positive**

- Spec text, script output, generated templates, and user-facing docs now agree on one name, removing a standing source of reader confusion.
- Downstream projects initialized before the rename keep working and stay idempotent; no migration step is imposed on users.
- The legacy-marker test makes the compatibility window explicit, so a future cleanup cannot silently break old projects without a failing test.
- The frozen V0.1-alpha baseline is untouched, so no versioned-baseline migration note is required.

**Negative / costs**

- `init.sh` carries a permanent one-line legacy condition and a second marker constant. This is accepted as cheaper than a migration that writes into user files.
- Archives and current docs use different abbreviations. A reader following an archived change will see `APPM`; the ADR and the change record explain why.
- Any external material already published under `APPM` (blog posts, forks, downstream copies) is now out of date. Nothing in this repository can fix that; the ADR is the record of the change.

## Alternatives considered

- **Docs-only rename, leaving `APPM` in specs and scripts.** Rejected: it creates exactly the drift this decision exists to remove, and leaves `init.sh` output disagreeing with the README.
- **Migrating legacy `.gitignore` markers in place.** Rejected: modifies user files beyond the initializer's stated contract and needs its own test surface; detection-only compatibility achieves idempotence without writing.
- **Rewriting archived changes to the new name.** Rejected: violates the lifecycle rule that history is not silently rewritten and would falsify evidence recorded in those changes.
- **Keeping `APPM` and documenting `APMF` as an alias.** Rejected: two live abbreviations is the original problem, not a solution.
- **Renaming the repository and remote.** Rejected: out of scope, disruptive to existing clones and worktrees, and not requested.

## Evidence and provenance

- Enumeration of every `APPM` occurrence before the change, and confirmation that the frozen baseline contains none: `.ai/archive/changes/apmf-rename-and-about/evidence.md`.
- Post-change residual audit (`grep -rn "APPM"` outside `.ai/archive/`) shows hits only in the intentional legacy-marker compatibility path, its test, and the change/NOW records describing the rename.
  - **Correction (2026-09-29, `fix/apmf-ci-name`):** that audit was extension-filtered (`--include="*.md" --include="*.sh"`) and therefore missed `.github/workflows/ci.yml`, which still declared `name: APPM CI`. The claim above was inaccurate as written. The workflow display name was renamed to `APMF CI` and the audit re-run with `git grep -n "APPM"` over **all** tracked files, which cannot miss a file type. Remaining hits are the legacy-marker compatibility path in `scripts/init.sh`, its test, and text describing the rename (this ADR, `CHANGELOG.md`). See `.ai/archive/changes/apmf-rename-followup/evidence.md`.
- Legacy-marker compatibility verified by `tests/test_v01_structure.sh` checks: `legacy marker fixture prepared`, `re-init on a legacy-marker project is safe`, `legacy marker is not rewritten`, `legacy marker does not gain a duplicate block`.
- Frozen README phrases verified by `./tests/test_v01_baseline.sh` after the README redesign.
- Full suite (`bash -n`, `validate.sh`, baseline, structure, integrity, `git diff --check`) and GitHub CI results recorded in the same evidence file.
