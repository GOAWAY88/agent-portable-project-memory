# 📖 About APMF

**Agent-Portable Project Memory Framework (APMF)** is a vendor-neutral protocol and template for keeping a software project's durable context inside the repository itself, as Git-tracked Markdown — so that switching coding agents, onboarding a human, or returning after six months does not mean starting from zero.

## 🌱 Origin

Coding agents are effective but forgetful. Their working context lives in a chat session that belongs to one vendor, one machine, and one moment in time. When the session ends, the reasoning goes with it: why a design was rejected, which command actually reproduces a bug, what the buffer-ownership rules are, which assumption was verified last Tuesday and against which commit.

The next agent re-derives all of it from scratch — and sometimes re-derives it *wrong*, confidently repeating a mistake that had already been found and fixed. The same problem hits humans on rotation, and it hits hardest on long-lived projects where the expensive knowledge is precisely the knowledge that is not written down anywhere reviewable.

APMF started from a simple inversion: **stop treating project memory as a feature of the agent, and start treating it as a property of the repository.**

## 🎯 The problem it solves

| Without durable project memory | With APMF |
|---|---|
| Context is locked to one agent vendor's chat history | Context is plain Markdown in Git, readable by any agent or human |
| Decisions are re-litigated every session | Decisions are recorded once as ADRs, with evidence |
| "Is this still true?" has no answer | Claims carry `updated` and `verified_at_commit` provenance |
| Stale notes mislead confidently | Validation fails loudly on broken routes and unresolvable commits |
| Handoff means a long verbal briefing | Handoff means "read `AGENTS.md`, then `.ai/NOW.md`" |
| Memory grows without bound | Active memory stays bounded; history moves to archive |

## 🧭 Core principle

> **The repository owns project memory; an agent is a temporary worker.**

Everything else follows from that. Memory is data, not a prompt. It is stored broadly but retrieved narrowly: an agent loads the small routing layer and the one active change relevant to the task, not the whole history. And because the memory is in the repository, it is subject to the same discipline as code — reviewable in a diff, attributable to a commit, revertible when wrong.

## 🏛️ Design philosophy

APMF is deliberately boring technology: Markdown files, a directory convention, and a few hundred lines of POSIX-friendly Bash. That choice is not aesthetic.

- **Source and executable evidence outrank summaries.** A memory file is a claim; a test run is a fact. When they disagree, the fact wins.
- **Unverified observations are not canonical truth.** Captured notes stay marked as unverified until something checks them.
- **Every durable decision has provenance.** No orphan conclusions — each one points at the evidence and the commit that justified it.
- **Incorrect persistent memory is more dangerous than missing memory.** A missing note costs time; a wrong note costs correctness, because an agent will act on it confidently. When in doubt, mark a claim stale rather than leaving it authoritative.
- **Derived indexes are rebuildable and never canonical.** A future search index may speed up retrieval, but it must be regenerable from the Markdown and ignored by Git.
- **Agent-specific adapters never own project truth.** They may read and write the canonical files; they may not become the only way to access them.

The full list lives in [`docs/design-principles.md`](docs/design-principles.md).

## 👥 Who it is for

- **Teams using coding agents** who want agent handoffs — between models, vendors, or people — to be cheap and lossless.
- **Solo maintainers** of long-lived projects who routinely context-switch and cannot keep the whole system in their head.
- **Open-source projects** that want contributors (human or agent) to self-serve on architecture, conventions, and open work without a maintainer-mediated briefing.
- **Research and paper projects**, via the `paper` profile, where the experiment ledger — data version, seed, environment commit — *is* the primary artifact and losing it invalidates results.
- **Anyone wary of lock-in**: the memory format outlives any single agent product, and moving to a different tool costs nothing because nothing was ever stored in that tool.

## 🔀 How it differs

**From vendor memory features.** Those store context inside one product, opaque and non-portable. APMF stores it in your repository, where `git log`, `git blame`, code review, and any future tool all still work.

**From a vector database or RAG pipeline.** Those make retrieval fast but treat embeddings as the source of truth, which cannot be read, diffed, or argued with by a human. APMF keeps canonical truth in readable files; retrieval acceleration is explicitly deferred to an optional derived layer that must remain rebuildable.

**From `docs/` folders.** Most documentation drifts silently because nothing checks it. APMF adds an authority model, provenance fields, staleness rules, and a validator that fails CI when routes break, statuses are invalid, evidence commits cannot be resolved, or a finished change was never archived.

**From a project-management tool.** APMF is not a ticket tracker. Its "active change" is a working-memory unit — proposal, design, tasks, evidence — meant to be read by whoever is doing the work right now, then archived.

## 🚫 Non-goals

APMF intentionally does **not** provide a vector database, embeddings, MCP server, cloud service, automatic LLM summarizer, agent-specific hook, or ticket system. It does not attempt to judge whether a recorded decision is *substantively* correct — validation checks structure and provenance, never truth. And it does not require any runtime beyond Bash and Git.

## 🗺️ Where to go next

- 🚀 Install it into a project: see the [Quick start](README.md#-quick-start) in the README
- 🏗️ Understand the layer model: [`docs/architecture.md`](docs/architecture.md)
- 📜 Read the normative rules: [`spec/v0.1.md`](spec/v0.1.md), [`spec/v0.2-memory-integrity.md`](spec/v0.2-memory-integrity.md), [`spec/v0.3-profiles.md`](spec/v0.3-profiles.md)
- 🔮 See what is deferred and why: [`docs/roadmap.md`](docs/roadmap.md)
- 🧠 Learn how memory ages: [`docs/memory-lifecycle.md`](docs/memory-lifecycle.md), [`docs/memory-integrity.md`](docs/memory-integrity.md)
- 🤝 Hand off between agents: [`docs/agent-handoff.md`](docs/agent-handoff.md)

## ⚖️ License

See [`LICENSE`](LICENSE).
