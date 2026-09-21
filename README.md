# Agent-Portable Project Memory Framework

**V0.1 · experimental**

Switching coding agents should not mean losing a project's history, intent, or operating knowledge. This repository defines a small, vendor-neutral protocol and template for keeping that memory in the repository where every agent can inspect it.

## The principle

The repository owns project memory; an agent is a temporary worker. Memory is stored as human-readable Markdown, while agents load only the small, relevant slice needed for the current task. This is a framework/protocol and template, not an LLM memory database.

## What V0.1 includes

- layered memory (`AGENTS.md`, `.ai/NOW.md`, `.ai/INDEX.md`, knowledge, decisions, changes, archive)
- an explicit capture → verify → promote → retrieve → supersede → archive lifecycle
- authority, provenance, staleness, branch-awareness, and secrets rules
- active-change artifacts: proposal, design, tasks, and evidence
- bootstrap and checkpoint protocols for handoff between agents
- a portable project template and small Bash helpers

V0.1 intentionally does **not** include a vector database, embeddings, MCP server, cloud service, automatic LLM summarizer, or agent-specific hook. Future retrieval layers must remain derived from the canonical files.

## Architecture

```text
L0 bootstrap/routing   AGENTS.md · .ai/NOW.md · .ai/INDEX.md
L1 active work          .ai/changes/<change>/
L2 current truth         .ai/knowledge/ · .ai/decisions/
L3 history               .ai/archive/
L4 retrieval             filesystem + INDEX today; FTS/BM25 later (derived)
```

Executable evidence and current source outrank summaries. Archives are never part of default startup context.

## Quick start

```bash
git clone <this-repository-url> agent-portable-project-memory
cd agent-portable-project-memory
./scripts/init.sh /path/to/my-project
```

The initializer refuses unsafe overwrites, preserves an existing `AGENTS.md`, and reports conflicts. In the target project, a new agent should read `AGENTS.md`, `.ai/NOW.md`, and `.ai/INDEX.md`, inspect Git state, then retrieve only the active change and relevant knowledge.

Use `./scripts/context.sh [project]` for a concise reconstruction view, `./scripts/checkpoint.sh [project]` before handoff, and `./scripts/validate.sh [project]` for structural checks.

## Designed portability

The format is designed to be portable across Codex, Cursor, Qwen Code, Claude Code, and other repository-aware coding agents. Compatibility is a design goal, not a claim that every agent has been tested.

See [`docs/architecture.md`](docs/architecture.md), [`spec/v0.1.md`](spec/v0.1.md), and [`template/`](template/) for details.
