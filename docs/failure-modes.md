# Failure modes

| Risk | Example | Mitigation |
|---|---|---|
| Memory drift | `NOW.md` names an old API | verify source/tests and record commit |
| Memory poisoning | an unverified guess is promoted | provenance, status, review before promotion |
| Error amplification | one wrong ADR guides many agents | evidence outranks summaries; supersede explicitly |
| Duplicate truth | architecture copied into three files | keep routing in INDEX, truth in one canonical file |
| Context inflation | startup reads all history | bounded L0 and targeted retrieval |
| Summary loss | vague checkpoint omits conditions | structured evidence and next action |
| Cross-agent semantics | one agent interprets status differently | normative schema/status vocabulary |
| Git conflicts | agents append one shared log | change-scoped and ADR-per-file artifacts |
| Branch/memory mismatch | evidence from another branch | record branch and SHA; verify checkout |
| Stale decisions | accepted ADR no longer applies | status and `superseded_by` |
| Unconditioned experiments | benchmark result without environment | record command, conditions, commit |
| Secrets leakage | token copied into an evidence file | secrets policy, review, ignore local runtime |
| Repository pollution | database cache committed | ignore derived paths; rebuild from Markdown |
| Retrieval failure | INDEX points to deleted file | validate links/paths and use search fallback |
| Over-constraining agents | notes treated as unbreakable rules | distinguish MUST from guidance; source wins |
| Vendor lock-in | proprietary memory format required | plain Markdown and shell only |

Incorrect memory is a safety issue, not merely a documentation defect.
