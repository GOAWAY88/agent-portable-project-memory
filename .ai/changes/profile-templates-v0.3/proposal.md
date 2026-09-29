# Proposal: profile-templates-v0.3

## Problem

APPM templates assume a software project: `init.sh` always seeds `PROJECT.md`, `ARCHITECTURE.md`, `COMMANDS.md`, `ENVIRONMENT.md`, and `validate.sh` hard-codes `PROJECT.md ARCHITECTURE.md COMMANDS.md` as required. A research/paper project cares about research questions, methods, and experiment records (data versions, seeds, environment commits), not build commands. Such projects currently must hand-edit generated memory and cannot pass validation with their own knowledge set.

## Motivation

Different project purposes need different durable-knowledge seeds while sharing one protocol. Making the knowledge set declarative keeps APPM vendor-neutral and domain-neutral without forking the lifecycle model.

## Scope

- Add `template/profiles/software/` (current knowledge set, default) and `template/profiles/paper/` (PROJECT, RESEARCH_QUESTIONS, METHODS, EXPERIMENTS seeds plus a paper-oriented INDEX variant).
- `init.sh --profile <name>`: seed knowledge and INDEX from the profile, write a declarative `.ai/profile.md` manifest (name + required knowledge list) into the generated project. Default remains `software` with byte-identical behavior for existing callers except the added manifest.
- `validate.sh`: when `.ai/profile.md` exists, validate the profile name and required knowledge from the manifest; when absent, keep the current hard-coded software defaults (backward compatible).
- Spec `spec/v0.3-profiles.md`, roadmap update, structure tests for default/paper/invalid profiles, and a paper-profile lifecycle validation test.
- Dogfood: add `.ai/profile.md` (software) to this repository.

## Non-goals

No automatic project-type detection (detection may only ever suggest, per roadmap); no changes to the four-artifact change model, status vocabularies, provenance rules, or the frozen V0.1-alpha baseline; no retrieval layer; no new runtime dependencies.

## Success criteria

`init.sh` with no arguments behaves as before (plus the manifest) and generated projects validate; `init.sh --profile paper` generates a validating paper project whose required knowledge is RESEARCH_QUESTIONS/METHODS/EXPERIMENTS-based; an unknown profile fails with a clear error; a project whose manifest-required knowledge file is missing fails validation; this repository validates with its own manifest; the full suite (`bash -n`, `validate.sh`, baseline, structure, integrity) passes locally and in GitHub CI on Ubuntu and macOS.
