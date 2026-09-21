# Memory lifecycle

```text
CAPTURE → VERIFY → PROMOTE → RETRIEVE → SUPERSEDE → ARCHIVE
```

- **Capture:** record an observation, idea, workaround, user decision, or experiment. It is not truth yet.
- **Verify:** check source, tests, reproducible output, external documentation, or human confirmation. Include conditions and provenance.
- **Promote:** move durable, useful, sufficiently verified claims into knowledge or an ADR. Keep the evidence link.
- **Retrieve:** load only files relevant to the current task; use `INDEX.md` and search rather than recursive reads.
- **Supersede:** mark replaced knowledge/decisions and point to the replacement. Never silently rewrite history.
- **Archive:** move completed changes and obsolete episodic material out of active paths. Preserve compact summaries, not raw chat transcripts.

An active change remains active while any task is `TODO`, `IN_PROGRESS`, or `BLOCKED`. On completion, record validation in `evidence.md`, promote durable results, and archive the change.
