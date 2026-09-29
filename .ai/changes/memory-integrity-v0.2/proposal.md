# Proposal: memory-integrity-v0.2

## Problem

Portable Markdown only helps when stale pointers, malformed status, missing provenance, and completed active changes are visible before they mislead another agent.

## Motivation

Make memory drift detectable and prevent silent protocol regressions before investing in faster retrieval.

## Scope

Strengthen `validate.sh`; add integrity and compatibility tests; create GitHub CI; freeze the V0.1-alpha contract; document V0.2 rules.

## Non-goals

No SQLite/FTS, BM25, vector database, MCP service, semantic retrieval, or agent adapter.

## Success criteria

Malformed active state, broken index paths, invalid statuses, missing provenance/evidence, unresolvable commits, and unarchived completed changes fail validation. CI runs the suite on Linux and macOS.
