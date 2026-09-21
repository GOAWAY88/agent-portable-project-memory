#!/usr/bin/env bash
set -u
ROOT=${1:-.}; ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "context: target missing" >&2; exit 2; }
echo "Project: $(basename "$ROOT")"
echo "Branch: $(git -C "$ROOT" branch --show-current 2>/dev/null || echo unknown)"
echo "Commit: $(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
echo "Git status:"
git -C "$ROOT" status --short 2>/dev/null | head -20 || true
echo "Memory:"
if [[ -f "$ROOT/.ai/NOW.md" ]]; then
  sed -n -E '/^(Project:|Milestone:|Active change:|Current task:|Blockers:|Next action:|Last verified state:)/p' "$ROOT/.ai/NOW.md" | head -8
else echo "  .ai/NOW.md not found"; fi
echo "Pointers: .ai/INDEX.md; active change named by NOW.md; archives are excluded."
