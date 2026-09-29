# Design: apmf-rename-and-about

## Approach

Treat the rename as a **protocol-visible string change with a compatibility window**, not a cosmetic edit.

**Naming.** `APMF` replaces `APPM` everywhere outside `.ai/archive/`. Archives are left untouched on purpose: `docs/memory-lifecycle.md` says superseded material is marked, never silently rewritten, and archived changes are historical evidence of what the text said at the time. The full name "Agent-Portable Project Memory Framework" is unchanged, so the frozen V0.1-alpha baseline — which never used the abbreviation — is unaffected.

**The `.gitignore` marker.** `init.sh` currently writes and greps one literal marker. The fix keeps a single canonical marker for *writing* (`# APMF derived/local memory infrastructure`) but widens the *detection* to accept either the new or the legacy `# APPM …` marker:

```bash
elif ! grep -qF '# APMF derived/local memory infrastructure' "$TARGET/.gitignore" \
  && ! grep -qF '# APPM derived/local memory infrastructure' "$TARGET/.gitignore"; then
```

A project initialized before the rename therefore still counts as "already has APPM runtime rules", gets no second block, and is left byte-identical. Migrating old markers in place was rejected: rewriting a user's `.gitignore` is a side effect beyond the initializer's contract, and the legacy marker is harmless.

**Tests.** The two existing assertions that grep the marker switch to the APMF string, and one new check initializes a project, rewrites its marker back to the legacy `# APPM` form, re-runs `init.sh`, and asserts the block still appears exactly once. That pins the compatibility window so a future cleanup cannot silently break old projects.

**README emoji.** Emoji go in section headings and a few list bullets only. Body prose, code blocks, the architecture diagram, and command examples stay plain, because those are read by agents and copied into terminals. The three baseline phrases are preserved verbatim and re-checked by running `test_v01_baseline.sh` after the edit rather than assumed.

**ABOUT.md.** A narrative document, deliberately *not* a duplicate of README: origin and the problem with agent-locked memory, the core principle, design philosophy drawn from `docs/design-principles.md`, who it is for, how it differs from vendor memory features and from a vector database, and explicit non-goals. It links to the specs instead of restating them, keeping `INDEX.md` as the router and avoiding a second source of truth.

**ADR-0001.** The rename is a durable decision with compatibility consequences, so it is recorded as the repository's first ADR using `template/.ai/decisions/ADR-TEMPLATE.md`, status `accepted`, with the test run and CI result as evidence. `.ai/decisions/README.md` currently claims no ADRs exist and is updated to route to `ADR-0001`.

## Tradeoffs

Accepting two markers forever is slightly untidy, but the alternative — a migration step that edits user files — trades a permanent one-line condition for a risky write into someone else's `.gitignore`. Emoji improve scannability for humans at the cost of a little noise for agents parsing headings; keeping them out of prose and code limits that cost. A separate `ABOUT.md` adds one more document to keep current, but folding the narrative into README would push README further past its "quick orientation" role.

## Risks

- Missing an `APPM` occurrence would leave the docs self-contradictory. Mitigated by enumerating every hit with `grep -rn "APPM"` before editing and re-running it afterward, expecting hits only under `.ai/archive/` and in the legacy-marker path.
- Editing README could drop a frozen baseline phrase and break CI. Mitigated by running `test_v01_baseline.sh` immediately after the README edit, before any other work.
- The widened marker check could mask a genuinely missing block if a project coincidentally contains the string `# APPM derived/local memory infrastructure` in a comment. That is the same risk the original single-marker check already carried, and the string is specific enough to make a false positive implausible.
- Adding `ABOUT.md` to `.ai/INDEX.md` introduces a new routed path; `validate.sh` existence-checks every INDEX path, so a typo would fail loudly rather than silently. The suite is run after the edit.

## Rejected alternatives

- **Docs-only rename, leaving `APPM` in specs and scripts:** creates exactly the drift this change exists to remove, and leaves `init.sh` user-facing output disagreeing with the README.
- **Rewriting legacy `.gitignore` markers in place:** modifies user files beyond the initializer's stated contract and would need its own test surface; detection-only compatibility achieves idempotence without writing.
- **Editing archived changes to the new name:** violates the lifecycle rule that history is not silently rewritten, and would falsify the evidence recorded in those changes.
- **Renaming the repository/directory/remote:** out of scope, disruptive to existing clones and worktrees, and not requested.
- **Putting the About narrative inside README:** README is the quick-start entry point; a long narrative there would bury the commands agents actually need.
