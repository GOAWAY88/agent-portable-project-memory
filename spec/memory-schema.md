# Memory schema

Markdown is the canonical format. Front matter is recommended for durable/high-authority artifacts, not required for every note.

## NOW.md

Required: project/milestone, active change, current task, blockers, next action, and last verified branch/commit. Recommended: pointers and updated date. Keep roughly 500–1500 tokens; replace old entries instead of appending.

## INDEX.md

Required: concise routes for project, architecture, environment/commands, current work, decisions, experiments, and archive. Paths must be repo-relative and point to canonical files.

## Knowledge document

Required: title and current claim. Recommended: `id`, `status`, `updated`, `verified_at_commit`, `related`, and `evidence`. Optional: owner, expiry/review date.

## ADR

Required: id/title, status (`proposed`, `accepted`, `rejected`, `deprecated`, `superseded`), context, decision, consequences. Recommended: created/updated, branch/SHA, alternatives, evidence, `supersedes`, `superseded_by`.

## Active change artifacts

- `proposal.md`: problem, motivation, scope, non-goals, success criteria.
- `design.md`: approach, interfaces, tradeoffs, risks, rejected alternatives.
- `tasks.md`: active checklist with one of the four task statuses.
- `evidence.md`: commands/results, environment, branch/SHA, conditions, and unresolved issues; link large raw logs rather than embedding them.

## Session/experiment summaries

Optional archive artifacts. Keep compact: Goal, Changes/Method, Findings, Decision, Evidence/conditions, Unresolved, Next, Commit. Never store raw chat transcripts or secrets.
