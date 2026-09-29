# Roadmap

## V0.1 (frozen alpha baseline)

Portable Markdown, layered routing, active changes, provenance, authority/staleness rules, archives, and minimal POSIX-friendly helpers. The compatibility contract is frozen in `spec/baselines/v0.1-alpha.md`.

## V0.2 (Memory Integrity)

Structural and provenance validation, negative tests, idempotence checks, and GitHub CI. Completed changes must leave the active area; broken routes and unresolvable evidence commits fail early.

## Possible later versions

- project profiles at init time (candidate V0.3): keep the L0–L3 protocol, change
  four-artifact lifecycle, provenance rules, and status vocabularies domain-neutral,
  but let `init.sh --profile <name>` seed different knowledge files and handoff
  checklists (e.g. `software`: ARCHITECTURE/COMMANDS/ENVIRONMENT; `paper`:
  RESEARCH_QUESTIONS/METHODS/EXPERIMENTS/WRITING with data-version, seed, and
  environment provenance in evidence). The profile declares its required knowledge
  set so `validate.sh` stops hard-coding PROJECT/ARCHITECTURE/COMMANDS. Profile
  selection is explicit and recorded as provenance; repository-type detection may
  only suggest a default, never decide silently. Default profile preserves current
  behavior and the frozen V0.1-alpha baseline.
- optional generated FTS5/BM25 retrieval index
- dependency-aware task graph
- agent adapters that remain clients of canonical files
- richer link and stale-reference checks
- optional MCP or cloud integrations

These must preserve the canonical repository format and remain opt-in.
