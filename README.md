<div align="center">

# 🧠 Agent-Portable Project Memory Framework

### **APMF** — your project's memory lives in Git, not in a chat window

**V0.3 · experimental (V0.1-alpha baseline frozen)**

[![APMF CI](https://github.com/GOAWAY88/agent-portable-project-memory/actions/workflows/ci.yml/badge.svg)](https://github.com/GOAWAY88/agent-portable-project-memory/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-blue)
![Dependencies](https://img.shields.io/badge/dependencies-none-success)
![Format](https://img.shields.io/badge/format-Markdown%20%2B%20Bash-lightgrey)

[**📖 About**](ABOUT.md) · [**🚀 Quick start**](#-quick-start) · [**🏛️ Architecture**](#-architecture) · [**📜 Spec**](spec/v0.1.md) · [**🔮 Roadmap**](docs/roadmap.md)

</div>

---

## 💡 Why

Switching coding agents should not mean losing a project's history, intent, or operating knowledge. Every time context lives only in a chat session, the next agent — or the next human — starts from zero and re-derives decisions that were already made, verified, and then forgotten.

APMF is a small, vendor-neutral **protocol and template** that keeps that memory in the repository, where every agent can inspect it and every claim can be verified against source.

## 🧭 The principle

> **The repository owns project memory; an agent is a temporary worker.**

Memory is stored as human-readable Markdown, while agents load only the small, relevant slice needed for the current task. This is a framework/protocol and template — **not an LLM memory database**.

## ✨ What's included

- 🗂️ **Layered memory** — `AGENTS.md`, `.ai/NOW.md`, `.ai/INDEX.md`, knowledge, decisions, changes, archive
- 🔄 **Explicit lifecycle** — capture → verify → promote → retrieve → supersede → archive
- 🧾 **Provenance & authority rules** — staleness, branch-awareness, and secrets handling
- 📦 **Active-change artifacts** — proposal, design, tasks, and evidence for every unit of work
- 🤝 **Handoff protocols** — bootstrap and checkpoint flows for switching agents safely
- 🧩 **Project profiles** (V0.3) — `init.sh --profile software|paper` seeds domain-appropriate knowledge, and a declarative `.ai/profile.md` manifest drives required-knowledge validation
- 🛡️ **Integrity validation** (V0.2) — structural checks, negative tests, idempotence checks, and GitHub CI on Linux/macOS
- 🔎 **Optional retrieval index** (V0.6) — rebuildable SQLite FTS5/BM25 search derived from canonical Markdown
- 🔗 **Reference integrity** (V0.7) — read-only detection of missing and stale current-memory routes
- 🐚 **Portable helpers** — a project template plus small Bash scripts, with no runtime dependencies

### 🚫 Deliberately excluded

V0.1 intentionally does **not** include a vector database, embeddings, MCP server, cloud service, automatic LLM summarizer, or agent-specific hook. Future retrieval layers must remain derived from the canonical files.

V0.2 kept that boundary until canonical Markdown integrity was stable. V0.6 adds only an optional, disposable SQLite FTS5/BM25 index; MCP, semantic retrieval, and agent adapters remain deferred. The frozen compatibility contract is [`spec/baselines/v0.1-alpha.md`](spec/baselines/v0.1-alpha.md). V0.3 keeps the protocol domain-neutral while making the seeded knowledge set declarative ([`spec/v0.3-profiles.md`](spec/v0.3-profiles.md)).

## 🏛️ Architecture

```text
L0 bootstrap/routing   AGENTS.md · .ai/NOW.md · .ai/INDEX.md
L1 active work          .ai/changes/<change>/
L2 current truth         .ai/knowledge/ · .ai/decisions/
L3 history               .ai/archive/
L4 retrieval             filesystem + INDEX; optional FTS5/BM25 (derived)
```

⚖️ Executable evidence and current source outrank summaries. 📁 Archives are never part of default startup context.

## 🚀 Quick start

```bash
git clone <this-repository-url> agent-portable-project-memory
cd agent-portable-project-memory
./scripts/init.sh /path/to/my-project              # software profile (default)
./scripts/init.sh --profile paper /path/to/my-paper  # research/paper profile
```

The initializer refuses unsafe overwrites, preserves an existing `AGENTS.md`, and reports conflicts. It installs the chosen profile's knowledge seeds, INDEX router, and a `.ai/profile.md` manifest declaring the project's required knowledge set. Profile names are restricted to `^[a-z][a-z0-9-]*$`, a profile must ship `profile.md`, `INDEX.md`, and `knowledge/`, and the overlay is applied all-or-nothing: if the target already holds a different profile or a differing router, `init.sh` reports the conflicts, writes nothing, and exits non-zero. Re-running the same profile is idempotent. In the target project, a new agent should read `AGENTS.md`, `.ai/NOW.md`, and `.ai/INDEX.md`, inspect Git state, then retrieve only the active change and relevant knowledge.

### 🧰 Helper scripts

| Purpose | Command |
|---|---|
| 🔍 Concise reconstruction view | `./scripts/context.sh [project]` |
| ✅ Pre-handoff checklist | `./scripts/checkpoint.sh [project]` |
| 🧾 Close commit provenance | `./scripts/close-provenance.sh [--check] [project]` |
| 📦 Archive completed change | `./scripts/archive-change.sh [--check] <project> <change>` |
| 🔎 Rebuild/search derived index | `./scripts/index-memory.sh [--query <term>] <project>` |
| 🔗 Check current-memory references | `./scripts/check-references.sh <project>` |
| 🛡️ Structural & integrity checks | `./scripts/validate.sh [project]` |

## 🌐 Designed portability

The format is designed to be portable across Codex, Cursor, Qwen Code, Claude Code, and other repository-aware coding agents. Compatibility is a design goal, not a claim that every agent has been tested.

## 📚 Further reading

- 📖 [`ABOUT.md`](ABOUT.md) — why this project exists and who it is for
- 🏗️ [`docs/architecture.md`](docs/architecture.md) — layer model and startup behavior
- 📜 [`spec/v0.1.md`](spec/v0.1.md) · [`spec/v0.2-memory-integrity.md`](spec/v0.2-memory-integrity.md) · [`spec/v0.3-profiles.md`](spec/v0.3-profiles.md)
- 🔎 [`spec/v0.6-retrieval-index.md`](spec/v0.6-retrieval-index.md) — optional derived FTS5/BM25 retrieval
- 🔗 [`spec/v0.7-reference-integrity.md`](spec/v0.7-reference-integrity.md) — current-memory stale-route checks
- 🧭 [`docs/design-principles.md`](docs/design-principles.md) — the twelve rules behind the format
- 🔮 [`docs/roadmap.md`](docs/roadmap.md) — what is deferred, and why
- 🧩 [`template/`](template/) — what an initialized project receives

---

<div align="center">

**📝 Memory is data, not the prompt.** Incorrect persistent memory is more dangerous than missing memory.

[⬆ Back to top](#-agent-portable-project-memory-framework)

</div>
