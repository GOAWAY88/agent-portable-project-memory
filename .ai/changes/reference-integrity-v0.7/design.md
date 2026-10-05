---
id: reference-integrity-v0.7-design
status: draft
created: 2026-10-05
updated: 2026-10-05
verified_at_commit: unknown
---
# Design: Current-memory reference checker

## Approach

`scripts/check-references.sh` scans only current `.ai/` Markdown: `NOW.md`, `INDEX.md`, knowledge files, and non-template decision files. It extracts inline-code paths and relative Markdown links, ignores URLs and placeholders containing angle brackets, and checks each local path from the project root.

When a missing path matches `.ai/changes/<name>/...` and the corresponding `.ai/archive/changes/<name>/...` exists, the diagnostic identifies it as a stale active route and prints the archive destination. Other missing local routes receive a direct missing-reference error. Historical archive files are never recursively scanned.

`validate.sh` additionally checks that an ADR's front-matter `evidence` path exists. The checker and validator remain read-only.

## Tradeoffs

- Restricting the scan to current `.ai/` avoids rewriting or judging historical evidence and avoids treating general project documentation as canonical memory routes.
- Inline-code extraction catches the route style used by APMF while intentionally avoiding a full Markdown parser.
- The checker reports all failures in one run, which is useful in CI and handoff reviews.

## Risks

- A legitimate custom path written in prose may be interpreted as a local route; the accepted syntax is deliberately limited to known repository prefixes.
- Markdown link destinations with anchors are normalized before checking, but unusual URL escaping is outside scope.

## Rejected alternatives

- **Automatically repair every missing path:** rejected because the intended destination cannot be inferred safely.
- **Scan all historical archives:** rejected because archives are immutable evidence and are not part of default current context.
- **Use a full Markdown parser:** rejected because the protocol's Bash helpers should remain portable without a package dependency.
