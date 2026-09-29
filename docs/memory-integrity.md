# Memory integrity in V0.2

V0.2 treats validation as a guardrail against silent memory drift. `scripts/validate.sh` remains dependency-free and checks a deliberately narrow Markdown convention rather than attempting to parse arbitrary YAML.

It checks the NOW router, local INDEX paths, knowledge/ADR metadata and statuses, resolvable commit provenance, active-change headings/tasks/evidence, completed-change archival, and tracked runtime databases. Template placeholders are allowed only so a freshly initialized project can be inspected before its first real change is created.

The canonical `.ai/changes/` directory itself is tracked with a small README, so archiving the last active change cannot make the required directory disappear from a Git checkout.

The validator does not infer whether a decision is substantively correct. Source code, tests, and reproducible evidence still outrank memory. A historical commit may be valid evidence even when it is not `HEAD`; a non-resolving commit is an integrity error.

CI runs on Linux and macOS to catch shell portability regressions. Retrieval optimization is intentionally deferred until these canonical invariants are stable.
