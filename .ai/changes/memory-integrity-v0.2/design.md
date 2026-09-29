# Design: memory-integrity-v0.2

## Approach

Keep the validator dependency-free and Bash-compatible. It parses only constrained Markdown conventions: NOW labels/front matter, inline-code index paths, knowledge/ADR front matter, task status tokens, and artifact headings. It verifies referenced Git objects without asserting that historical evidence must equal `HEAD`.

## Interfaces and affected paths

`scripts/validate.sh`, `tests/`, `.github/workflows/ci.yml`, `spec/v0.2-memory-integrity.md`, `spec/baselines/v0.1-alpha.md`, and root dogfood memory.

## Tradeoffs

The parser intentionally validates a narrow convention rather than becoming a general Markdown/YAML parser. Unknown commit is allowed for a newly initialized template; a supplied SHA must resolve in the repository.

## Risks

Strict rules can make early adoption noisy. Error messages name the artifact and expected convention; generated templates start with no active change to avoid fabricated evidence.

## Rejected alternatives

Adding a database/index first would make retrieval faster without making canonical claims trustworthy. Full YAML/Markdown dependencies would reduce portability for V0.2.
