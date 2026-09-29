#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
for path in AGENTS.md .ai/NOW.md .ai/INDEX.md .ai/knowledge .ai/decisions .ai/changes .ai/archive; do
  [[ -e "$ROOT/$path" ]] && ok "baseline path $path" || bad "baseline path $path"
done
for phrase in "repository owns project memory" "V0.1" "not an LLM memory database"; do
  grep -qi "$phrase" "$ROOT/README.md" && ok "README baseline phrase: $phrase" || bad "README baseline phrase: $phrase"
done
grep -q 'template/.ai' "$ROOT/spec/baselines/v0.1-alpha.md" 2>/dev/null || true
[[ -f "$ROOT/template/.ai/changes/_template/proposal.md" && -f "$ROOT/template/.ai/changes/_template/design.md" && -f "$ROOT/template/.ai/changes/_template/tasks.md" && -f "$ROOT/template/.ai/changes/_template/evidence.md" ]] \
  && ok 'baseline active-change template' || bad 'baseline active-change template'
(( fail == 0 )) && { echo 'V0.1-alpha baseline passed'; exit 0; }
echo 'V0.1-alpha baseline failed'; exit 1
