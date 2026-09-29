# Design: profile-templates-v0.3

## Approach

Split the template tree into a shared core and per-profile overlays:

```text
template/
  AGENTS.md                     # domain-neutral, unchanged
  .ai/                          # shared: NOW.md, README.md, archive/, changes/_template/, decisions/
  profiles/
    software/
      profile.md                # manifest source: name + required_knowledge
      INDEX.md                  # knowledge rows for software
      knowledge/                # PROJECT, ARCHITECTURE, COMMANDS, ENVIRONMENT
    paper/
      profile.md
      INDEX.md
      knowledge/                # PROJECT, RESEARCH_QUESTIONS, METHODS, EXPERIMENTS, ENVIRONMENT
```

`init.sh` gains `--profile <name>` (default `software`). It copies the shared `.ai/` core, then the profile's `knowledge/`, `INDEX.md`, and `profile.md` (installed as `.ai/profile.md`). `template/.ai/knowledge/` and `template/.ai/INDEX.md` move into `template/profiles/software/`; the shared core no longer contains knowledge files or INDEX.

The manifest is plain front-matter Markdown so the no-parser constraint holds:

```markdown
---
name: paper
required_knowledge: PROJECT.md RESEARCH_QUESTIONS.md METHODS.md EXPERIMENTS.md
---
```

`validate.sh` reads `.ai/profile.md` when present: the name must match `^[a-z][a-z0-9-]*$`, every `required_knowledge` entry must exist in `.ai/knowledge/`, and the INDEX must still route. When the manifest is absent, the validator falls back to today's hard-coded `PROJECT.md ARCHITECTURE.md COMMANDS.md` check, so every existing initialized project keeps validating unchanged.

## Tradeoffs

Moving `template/.ai/knowledge/` and `template/.ai/INDEX.md` into `profiles/software/` touches existing paths, but keeping duplicates in both places would create two sources of truth for the default seed. The manifest lives inside the generated project (not in the framework repo) so validation never depends on framework files being present. `ENVIRONMENT.md` ships in the paper profile as a seed but is not required, since not every paper project has a fixed compute environment.

## Risks

- `test_v01_structure.sh` and `test_memory_integrity.sh` fixtures call `init.sh` and expect `.ai/knowledge/PROJECT.md` and the software INDEX rows; the software profile reproduces both, so fixtures keep passing. Verified by running the suite after the move.
- The frozen baseline test checks `template/.ai/changes/_template/*` and repo-level paths only; it does not reference `template/.ai/knowledge/`, so the move is baseline-safe. `spec/baselines/v0.1-alpha.md` requires the `.ai/knowledge/` directory, not specific file names.
- `validate.sh`'s knowledge loop already validates front matter/status for whatever files exist; the manifest check adds required-file existence on top without changing per-file rules.
- Older checkouts with a hand-made `.ai/profile.md` of a different shape: the validator rejects malformed names/lists loudly rather than silently, consistent with V0.2 integrity behavior.

## Rejected alternatives

- Hard-coding a `paper` case inside `validate.sh`: violates the roadmap decision that the profile declares its required set; every new profile would need a validator change.
- Auto-detecting the project type from files (`CMakeLists.txt`, `*.tex`): fragile for mixed projects, violates "detection may only suggest, never decide silently", and injects unverified inference into canonical memory.
- Separate `init-paper.sh` script: duplicates shared logic and drifts.
- JSON/YAML manifest: breaks the no-parser, plain-Markdown constraint.
