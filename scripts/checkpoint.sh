#!/usr/bin/env bash
set -u
ROOT=${1:-.}; ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "checkpoint: target missing" >&2; exit 2; }
echo "Checkpoint for $ROOT"
echo "Branch: $(git -C "$ROOT" branch --show-current 2>/dev/null || echo unknown)"
echo "Commit: $(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
echo "Status:"; git -C "$ROOT" status --short 2>/dev/null || true
active=$(sed -n 's/^Active change:[[:space:]]*\*\*\([^*]*\)\*\*.*$/\1/p' "$ROOT/.ai/NOW.md" 2>/dev/null | head -1)
echo "Active change: ${active:-unknown}"
echo
echo "Review before handoff:"
echo "  [ ] run relevant tests and scripts/validate.sh"
echo "  [ ] update active change tasks.md and evidence.md"
echo "  [ ] record durable decisions as individual ADRs"
echo "  [ ] promote verified knowledge; mark superseded/stale claims"
echo "  [ ] update .ai/NOW.md with branch, verified commit, blockers, and next action"
echo "  [ ] archive completed changes when appropriate"
