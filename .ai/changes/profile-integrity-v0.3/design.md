# Design: profile-integrity-v0.3

## Approach

All three fixes are validation-tightening in existing shell helpers; no new files are added to the canonical format and no dependency is introduced.

**1. Profile name and directory validation (`init.sh`).** Immediately after argument parsing, reject any `--profile` value that does not match `^[a-z][a-z0-9-]*$`. This single check rejects `..`, `../paper`, `paper/..`, `../../something`, and `BadName`, because none of them consist solely of a leading lowercase letter followed by lowercase alphanumerics or hyphens — crucially, `/` and `.` are not in the allowed set, so no value can escape `template/profiles/`. After the name check, require all three of `template/profiles/<name>/profile.md`, `template/profiles/<name>/INDEX.md`, and the `template/profiles/<name>/knowledge/` directory to exist, each with a distinct diagnostic. Only then is the profile considered usable.

**2. Fail on copy errors, report success last (`init.sh`).** `copy_if_missing` gains a `cp` exit-status check and aborts with non-zero on failure, so a missing source can never be announced as `CREATED:`. The overlay loop is rewritten to iterate a pre-built source/destination pair list, and `init: profile '<name>' applied` is emitted only after every overlay file has been successfully created or confirmed identical.

**3. Overlay preflight (`init.sh`).** Before any file is written — before `.gitignore`, `AGENTS.md`, and the shared core, not just before the overlay — build the overlay file list and classify each destination:

- absent → will be created;
- present and byte-identical to the profile seed (`cmp -s`) → idempotent, no write;
- present and differing → unacceptable conflict.

Separately, if `.ai/profile.md` already exists, parse its `name` front-matter and reject when it differs from the requested profile. If any unacceptable conflict exists, print each one, state that the profile was **not** applied and that manual merge is required, and exit non-zero without having written anything. This removes the mixed state by construction: the script either applies the profile completely or changes nothing.

**4. Strict knowledge filenames (`validate.sh`).** Each `required_knowledge` entry must match `^[A-Za-z0-9][A-Za-z0-9._-]*\.md$`. The character class excludes `/`, so `../AGENTS.md`, `../../AGENTS.md`, `foo/bar.md`, and `/tmp/x.md` are all rejected as traversal or non-local paths; the mandatory `.md` suffix rejects `file.txt`; the leading `[A-Za-z0-9]` rejects dotfiles and empty segments. Entries are split with `read -r -a` rather than unquoted expansion, so a value like `*.md` cannot be glob-expanded into real filenames before the check runs. Passing entries are still required to exist under `.ai/knowledge/`. The manifest-absent fallback to `PROJECT.md ARCHITECTURE.md COMMANDS.md` is untouched, preserving pre-V0.3 projects.

## Tradeoffs

Preflighting the overlay before the shared-core write means a conflicting profile leaves the target completely untouched rather than half-initialized. That is a deliberate change from the shared core's lenient "preserve and continue" behavior: the core is idempotent boilerplate where a conflict is informational, whereas the overlay defines which profile the project *is*, so a conflict there means the operator's intent cannot be honored and must stop. Keeping the core lenient preserves the frozen V0.1 idempotence tests; making the overlay strict satisfies the no-mixed-state requirement. `cmp -s` is used for identity because it is present on both Linux and macOS and avoids hashing overhead.

## Risks

- Existing tests call `init.sh` twice on the same project (`repeated init is safe`) and on a project with a pre-existing `AGENTS.md`/`.gitignore` (`init reports existing-file conflicts`). Both use the default `software` profile: the first re-applies an identical overlay (idempotent, exit 0), the second has no `.ai/` at all so every overlay file is absent (exit 0). Verified by running the suite after the change.
- The `software` and `paper` profiles share `PROJECT.md` and `ENVIRONMENT.md` filenames with different content. Switching profiles on an initialized project will therefore report those two as differing conflicts and exit non-zero. That is the intended safe behavior, not a regression: silently keeping one profile's `PROJECT.md` under another profile's manifest is exactly the mixed state being eliminated.
- Tests 4–6 need a profile directory missing a required file. Creating one inside the real repository would modify the user's project, so the tests copy `scripts/` and `template/` into a temporary directory and mutate the copy. `init.sh` derives `SOURCE_ROOT` from `BASH_SOURCE`, so the copied script resolves the copied template with no interface change.
- `read -r -a` and `cmp -s` are bash/POSIX utilities already assumed by the suite; no new dependency is added.

## Rejected alternatives

- Resolving `PROFILE_DIR` with `realpath` and checking it stays under `template/profiles/`: works, but adds a portability dependency (`realpath` is not guaranteed on macOS system bash) and still permits odd-but-valid names. The name regex is simpler, stricter, and dependency-free.
- Letting the overlay use the existing lenient `copy_if_missing` and only fixing the final message: would still write a partial overlay before failing, leaving a mixed tree.
- Normalizing `required_knowledge` paths (stripping `../`, resolving against `.ai/knowledge/`): silently reinterpreting a malformed manifest is worse than rejecting it, and contradicts the V0.2 principle that malformed provenance fails loudly.
- Adding a checksum manifest for overlay identity: `cmp -s` is sufficient, and a checksum file would be a second source of truth that can itself drift.
- Making the shared core strict as well: would break the frozen V0.1 idempotence and conflict-reporting behavior that `test_v01_structure.sh` asserts.
