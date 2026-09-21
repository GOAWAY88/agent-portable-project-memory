# Authority model

When claims conflict, use this descending order:

1. executable evidence, tests, reproducible benchmarks
2. current source code and configuration
3. current canonical specifications and project knowledge
4. accepted architectural decisions
5. active change artifacts
6. `.ai/NOW.md`
7. archived/session memory
8. agent inference or unverified assumptions

This is a conflict-resolution rule, not a license to ignore an ADR. Investigate why artifacts disagree, update stale memory, and preserve supersession/provenance. Verify branch and commit whenever a claim is branch-sensitive.
