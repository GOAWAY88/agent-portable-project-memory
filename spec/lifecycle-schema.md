# Lifecycle schema

| State | Meaning | Required action |
|---|---|---|
| CAPTURE | observation or proposal, not truth | label uncertainty |
| VERIFY | evidence is being gathered | record source, command, conditions |
| PROMOTE | durable claim accepted | place in knowledge/ADR with provenance |
| RETRIEVE | relevant context loaded | keep scope narrow |
| SUPERSEDE | replaced by newer truth | link replacement and retain history |
| ARCHIVE | no longer active | move out of startup paths |

An artifact may mention its lifecycle state in front matter or a heading. `tasks.md` statuses are `TODO`, `IN_PROGRESS`, `BLOCKED`, and `DONE`.
