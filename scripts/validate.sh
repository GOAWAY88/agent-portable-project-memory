#!/usr/bin/env bash
set -u

ROOT=${1:-.}
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "validate: target does not exist: ${1:-.}" >&2; exit 2; }
fail=0
need() { if [[ ! -e "$ROOT/$1" ]]; then echo "ERROR: missing $1" >&2; fail=1; fi; }

for p in AGENTS.md .ai/NOW.md .ai/INDEX.md .ai/knowledge .ai/decisions .ai/changes .ai/archive; do need "$p"; done
for p in PROJECT.md ARCHITECTURE.md COMMANDS.md; do need ".ai/knowledge/$p"; done

active=$(sed -n 's/^Active change:[[:space:]]*\*\*\([^*]*\)\*\*.*$/\1/p' "$ROOT/.ai/NOW.md" 2>/dev/null | head -n1)
if [[ -z "$active" ]]; then
  active=$(sed -n 's/^active_change:[[:space:]]*//p' "$ROOT/.ai/NOW.md" 2>/dev/null | head -n1)
fi
if [[ -n "$active" && "$active" != "none" && "$active" != "[active-change]" ]]; then
  for p in proposal.md design.md tasks.md evidence.md; do need ".ai/changes/$active/$p"; done
fi

shopt -s nullglob
for adr in "$ROOT"/.ai/decisions/ADR-*.md; do
  base=$(basename "$adr")
  [[ "$base" == "ADR-TEMPLATE.md" ]] && continue
  [[ "$base" =~ ^ADR-[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$ ]] || { echo "ERROR: invalid ADR filename: $base" >&2; fail=1; }
done

if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for f in .ai/index/example.sqlite .ai/runtime/example.db; do
    if git -C "$ROOT" ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      echo "ERROR: derived runtime file is tracked: $f" >&2; fail=1
    fi
  done
fi

if (( fail )); then echo "validate: FAILED" >&2; exit 1; fi
echo "validate: OK ($ROOT)"
