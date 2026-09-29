# Design: qwen-handoff-v0.1

## Approach

Keep the canonical directory set (`.ai/knowledge`, `.ai/decisions`, `.ai/changes`, `.ai/archive`) non-empty by tracking a small `README.md` in each. `.ai/decisions/` and `.ai/archive/` already do this; `.ai/changes/` is the only one that relied on transient content. Add `.ai/changes/README.md` explaining that the directory holds active changes and is archived to `.ai/archive/changes/` on completion. Harden `tests/test_v01_structure.sh` with two checks: (1) `git ls-files -- .ai/changes/` must be non-empty in this repository, so a future archival cannot silently delete the directory again; (2) an end-to-end lifecycle fixture that runs `init.sh` on a throwaway repo, creates an active change from `_template/`, flips every task to `DONE`, moves the change into `.ai/archive/changes/`, and asserts `validate.sh` still passes. The second check proves the archival path itself keeps `.ai/changes/` alive for downstream projects, which is the exact scenario that broke CI here.

## Tradeoffs

A placeholder file is one more thing to keep accurate, but it matches the existing README convention, is visible in the router-free part of the tree, and costs nothing at runtime. The repository-scoped `git ls-files` check guards this repo specifically; the lifecycle fixture guards the general archival behavior in any initialized project, so the two checks cover different failure surfaces rather than duplicating each other. The lifecycle fixture reuses the existing `init.sh` + `_template` copy pattern already present in `test_memory_integrity.sh`, keeping the new test consistent with established fixtures.

## Risks

- `validate.sh` iterates `.ai/changes/*` in `check_change`; it skips non-directories (`[[ -d "$change" ]] || continue`), so `README.md` cannot be mistaken for a change. Verified by reading the loop before implementation.
- The lifecycle fixture must archive the change (move it out of `.ai/changes/`) rather than leave it `DONE` in place, because `validate.sh` rejects a completed change that remains active. The fixture therefore exercises the real archival transition, not a shortcut.
- The new repository-scoped check uses `git ls-files`, which works in worktrees and clones; if the tests are ever run outside a Git checkout it would fail, but the whole suite already assumes a Git repository (baseline test resolves commits). The lifecycle fixture uses its own `git init` throwaway repo, so it is self-contained.

## Rejected alternatives

- Relaxing `validate.sh` to tolerate a missing `.ai/changes` directory: weakens the V0.2 integrity contract and the frozen baseline expectation that the path exists.
- Committing an empty-marker file like `.gitkeep`: less informative than a README that states the directory's role; deviates from the sibling-directory convention.
- Adding the placeholder only in `template/`: does not fix this repository, which is the failing CI target.
- Adding `template/.ai/changes/README.md`: unnecessary, because `init.sh` already copies the tracked `template/.ai/changes/_template/` artifacts, which keep the generated `.ai/changes/` directory alive; a second placeholder would be redundant.
