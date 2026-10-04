# Evidence: provenance-close-v0.4

| Date | Branch/SHA | Command or observation | Result |
|---|---|---|---|
| 2026-10-04 | main / 943f9cb | Read `.ai/NOW.md`, `.ai/INDEX.md`, current scripts/specs, and archived-change state | Confirmed the prior memory-maintenance change was integrated but not archived in the router; archived it before starting this change. Confirmed templates intentionally use unresolved provenance before a first commit. |
| 2026-10-04 | main / 943f9cb + working tree | `bash -n scripts/*.sh tests/*.sh`; `./scripts/validate.sh .`; `./tests/test_v01_baseline.sh`; `./tests/test_v01_structure.sh`; `./tests/test_memory_integrity.sh`; `git diff --check` | All passed. Structure coverage confirms unborn repositories are unchanged, first-commit placeholders bind to the full SHA, existing SHAs are preserved, repeated runs are idempotent, `--check` does not write, and `checkpoint.sh` invokes closeout. |
| 2026-10-04 | main / 943f9cb + working tree | `./scripts/checkpoint.sh .` | Passed; current framework has no unresolved placeholders, so it reported `provenance: updated 0 file(s)` and made no changes. |
| 2026-10-04 | main / 943f9cb + working tree | Explicit trailing-whitespace scan over new script, spec, and active-change files | Passed; new untracked files are whitespace clean. |
| 2026-10-04 | main / 7fcf70e + dogfood review | Inspected the initialized project's `ADR-TEMPLATE.md` and compared it with the closeout contract | Found and fixed a boundary bug: instructional ADR templates must retain `unknown` and are now excluded from closeout; a regression assertion covers this. |
