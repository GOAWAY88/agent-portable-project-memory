# Design principles

1. The repository is the memory owner.
2. Memory is data, not the prompt.
3. Persist broadly, retrieve narrowly.
4. Current state and history are separate.
5. Source and executable evidence outrank summaries.
6. Unverified observations are not canonical truth.
7. Every durable decision has provenance.
8. Active memory stays bounded.
9. Canonical format remains tool-independent.
10. Derived indexes are rebuildable.
11. Agent-specific adapters never own project truth.
12. Prefer explicit lifecycle over endless append-only files.

Incorrect persistent memory is often more dangerous than missing memory: agents may confidently repeat it. When in doubt, mark a claim unverified or stale and verify it against the repository.
