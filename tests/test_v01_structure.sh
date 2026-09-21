#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
check() { "$@" >/tmp/appm-test-output 2>&1 && ok "$1" || { cat /tmp/appm-test-output; bad "$1"; }; }

for p in AGENTS.md .ai/NOW.md .ai/INDEX.md .ai/knowledge/PROJECT.md .ai/decisions/README.md \
  .ai/changes/framework-v0.1/proposal.md template/AGENTS.md template/.ai/NOW.md \
  template/.ai/changes/_template/evidence.md scripts/init.sh scripts/context.sh scripts/checkpoint.sh scripts/validate.sh; do
  [[ -e "$ROOT/$p" ]] && ok "required file $p" || bad "required file $p"
done

check "$ROOT/scripts/validate.sh" "$ROOT"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp" /tmp/appm-test-output' EXIT
mkdir "$tmp/project"; git -C "$tmp/project" init -q; git -C "$tmp/project" config user.email test@example.invalid; git -C "$tmp/project" config user.name test
check "$ROOT/scripts/init.sh" "$tmp/project"
check "$ROOT/scripts/validate.sh" "$tmp/project"

printf '# existing instructions\n' > "$tmp/project/AGENTS.md"
check "$ROOT/scripts/init.sh" "$tmp/project"
grep -q 'existing instructions' "$tmp/project/AGENTS.md" && ok 'existing AGENTS.md preserved' || bad 'existing AGENTS.md preserved'

mkdir -p "$tmp/project/.ai/runtime"; touch "$tmp/project/.ai/runtime/cache.db"
git -C "$tmp/project" add .; git -C "$tmp/project" commit -qm init
if git -C "$tmp/project" check-ignore -q .ai/runtime/cache.db; then ok 'runtime files ignored'; else bad 'runtime files ignored'; fi

(( fail == 0 )) && { echo 'all structure tests passed'; exit 0; }
echo 'structure tests failed'; exit 1
