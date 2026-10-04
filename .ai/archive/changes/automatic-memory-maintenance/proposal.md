# Proposal: automatic-memory-maintenance

## Problem

An initialized project tells an agent to update memory before handoff, but it does not state strongly enough that memory maintenance is a default responsibility for every non-trivial task. A user may therefore feel required to repeat “update project memory” in every prompt.

## Motivation

APMF is useful only when agents preserve durable project state without relying on chat history or repeated human reminders. The default must be explicit, while trivial edits and ordinary conversation must not create noisy change records.

## Scope

- Strengthen the repository's own `AGENTS.md` and the generated `template/AGENTS.md`.
- Require automatic memory maintenance for non-trivial behavioral work.
- Define the active-change, knowledge/ADR promotion, handoff, and final-response expectations.
- Add a structure regression check proving new projects inherit the policy.

## Non-goals

No background daemon, semantic auto-writer, vendor-specific agent hook, or automatic capture of chat. No change to canonical Markdown, profile behavior, or the V0.1 baseline.

## Success criteria

The policy is present in both instruction files, a newly initialized project inherits it, trivial edits remain exempt, and the full local validation suite passes.
