# Design: qwen-handoff-v0.1

## Approach

Keep the canonical directory set (`.ai/knowledge`, `.ai/decisions`, `.ai/changes`, `.ai/archive`) non-empty by tracking a small `README.md` in each. `.ai/decisions/` and `.ai/archive/` already do this; `.ai/changes/` is the only one that relied on transient content. Add `.ai/changes/README.md` explaining that the directory holds active changes and is archived to `.ai/archive/changes/` on completion. Harden `tests/test_v01_structure.sh` with one check: `git ls-files -- .ai/changes/` must be non-empty in this repository, so a future archival cannot silently delete the directory again.

## Tradeoffs

A placeholder file is one more thing to keep accurate, but it matches the existing README convention, is visible in the router-free part of the tree, and costs nothing at runtime. The regression check is repository-scoped (runs against `$ROOT`), not against generated fixtures, because initialized projects keep `.ai/changes/` alive via the copied `_template/` artifacts.

## Risks

- `validate.sh` iterates `.ai/changes/*` in `check_change`; it skips non-directories (`[[ -d "$change" ]] || continue`), so `README.md` cannot be mistaken for a change. Verified by reading the loop before implementation.
- The new structure-test check uses `git ls-files`, which works in worktrees and clones; if the tests are ever run outside a Git checkout it would fail, but the whole suite already assumes a Git repository (baseline test resolves commits).

## Rejected alternatives

- Relaxing `validate.sh` to tolerate a missing `.ai/changes` directory: weakens the V0.2 integrity contract and the frozen baseline expectation that the path exists.
- Committing an empty-marker file like `.gitkeep`: less informative than a README that states the directory's role; deviates from the sibling-directory convention.
- Adding the placeholder only in `template/`: does not fix this repository, which is the failing CI target.
