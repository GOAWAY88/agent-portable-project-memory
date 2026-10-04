# Design: automatic-memory-maintenance

## Approach

Treat memory maintenance as part of task completion in the portable `AGENTS.md` contract. For non-trivial changes, agents create or reuse an active change, keep its four artifacts current, promote durable knowledge and decisions, update `NOW.md`, validate, and disclose memory updates at handoff.

## Interfaces and affected paths

- `AGENTS.md`: dogfood rule for this framework repository.
- `template/AGENTS.md`: vendor-neutral rule inherited by initialized projects.
- `tests/test_v01_structure.sh`: checks the generated file contains both the automatic-maintenance rule and the trivial-edit exception.

## Tradeoffs

Instructions improve consistent agent behavior without pretending that a shell script can infer semantic truth. The rule adds process to non-trivial work, so behavior-neutral edits are explicitly exempt.

## Risks

Different agents may interpret “non-trivial” differently. The policy anchors it to changes in code, configuration, interfaces, architecture, tests, or documented behavior and makes validation observable at handoff.

## Rejected alternatives

- A Git hook cannot determine whether memory is semantically accurate and is not portable across every agent.
- Recording every prompt would add noise, private material, and unverified claims to canonical memory.
