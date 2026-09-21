# Design: framework-v0.1

## Approach

Use Git-tracked Markdown in layered paths. Keep L0 concise; scope active changes per directory; represent durable decisions as individual ADRs; reserve ignored paths for future indexes/runtime data.

## Interfaces and affected paths

`AGENTS.md`, `.ai/`, `template/`, `scripts/`, `docs/`, `spec/`, and `tests/`. Scripts use Bash and standard Git/filesystem commands.

## Tradeoffs

Plain files are portable and reviewable but retrieval is manual in V0.1. Safety and human review take precedence over aggressive automation.

## Risks

Memory drift, stale branches, and concurrent edits remain possible; provenance, validation, and explicit handoff checklists mitigate them.

## Rejected alternatives

A single CONTEXT.md, mandatory database, recursive startup reads, and agent-specific private storage were rejected because they inflate context or reduce portability.
