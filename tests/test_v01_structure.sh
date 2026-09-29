#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
check() { local label=$1; shift; if "$@" >"$OUT" 2>&1; then ok "$label"; else cat "$OUT"; bad "$label"; fi; }
digest() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }

OUT=$(mktemp)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp" "$OUT"' EXIT

for p in AGENTS.md .ai/NOW.md .ai/INDEX.md .ai/knowledge/PROJECT.md .ai/decisions/README.md \
  .ai/archive/changes/memory-integrity-v0.2/proposal.md template/AGENTS.md template/.ai/NOW.md \
  template/.ai/changes/_template/evidence.md scripts/init.sh scripts/context.sh scripts/checkpoint.sh scripts/validate.sh; do
  [[ -e "$ROOT/$p" ]] && ok "required file $p" || bad "required file $p"
done

check 'root validates' "$ROOT/scripts/validate.sh" "$ROOT"
mkdir "$tmp/project"; git -C "$tmp/project" init -q; git -C "$tmp/project" config user.email test@example.invalid; git -C "$tmp/project" config user.name test
check 'init creates project memory' "$ROOT/scripts/init.sh" "$tmp/project"
check 'generated project validates' "$ROOT/scripts/validate.sh" "$tmp/project"

agents_before=$(digest "$tmp/project/AGENTS.md")
ignore_before=$(digest "$tmp/project/.gitignore")
check 'repeated init is safe' "$ROOT/scripts/init.sh" "$tmp/project"
[[ "$agents_before" == "$(digest "$tmp/project/AGENTS.md")" ]] && ok 'idempotent init preserves AGENTS.md' || bad 'idempotent init preserves AGENTS.md'
[[ "$ignore_before" == "$(digest "$tmp/project/.gitignore")" ]] && ok 'idempotent init preserves .gitignore' || bad 'idempotent init preserves .gitignore'
[[ $(grep -cF '# APPM derived/local memory infrastructure' "$tmp/project/.gitignore") -eq 1 ]] && ok 'idempotent init does not duplicate ignore block' || bad 'idempotent init does not duplicate ignore block'

mkdir "$tmp/existing"; git -C "$tmp/existing" init -q; git -C "$tmp/existing" config user.email test@example.invalid; git -C "$tmp/existing" config user.name test
printf '# keep me\n' > "$tmp/existing/AGENTS.md"
printf '# project rules\n*.local\n' > "$tmp/existing/.gitignore"
check 'init reports existing-file conflicts' "$ROOT/scripts/init.sh" "$tmp/existing"
grep -q 'keep me' "$tmp/existing/AGENTS.md" && ok 'existing AGENTS.md preserved' || bad 'existing AGENTS.md preserved'
grep -q '\*\.local' "$tmp/existing/.gitignore" && ok 'existing .gitignore rules preserved' || bad 'existing .gitignore rules preserved'
[[ $(grep -cF '# APPM derived/local memory infrastructure' "$tmp/existing/.gitignore") -eq 1 ]] && ok 'existing .gitignore gets one APPM block' || bad 'existing .gitignore gets one APPM block'

mkdir -p "$tmp/project/.ai/runtime"; touch "$tmp/project/.ai/runtime/cache.db"
git -C "$tmp/project" add .; git -C "$tmp/project" commit -qm init
git -C "$tmp/project" check-ignore -q .ai/runtime/cache.db && ok 'runtime files ignored' || bad 'runtime files ignored'

(( fail == 0 )) && { echo 'all structure tests passed'; exit 0; }
echo 'structure tests failed'; exit 1
