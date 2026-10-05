#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
tmp=$(mktemp -d)
out=$(mktemp)
trap 'rm -rf "$tmp" "$out"' EXIT

repo="$tmp/project"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email test@example.invalid
git -C "$repo" config user.name test
git -C "$repo" symbolic-ref HEAD refs/heads/main
"$ROOT/scripts/init.sh" "$repo" >/dev/null
git -C "$repo" add .
git -C "$repo" commit -qm initial

if "$ROOT/scripts/checkpoint.sh" "$repo" >"$out" 2>&1; then
  ok 'checkpoint closes provenance and runs doctor'
else
  cat "$out"; bad 'checkpoint closes provenance and runs doctor'
fi
git -C "$repo" add .ai/NOW.md .ai/knowledge .ai/decisions
git -C "$repo" commit -qm provenance

if "$ROOT/scripts/doctor.sh" --strict "$repo" >"$out" 2>&1; then
  bad 'strict doctor rejects absent optional index'
else
  grep -q 'optional retrieval index is absent' "$out" && ok 'strict doctor rejects absent optional index' || { cat "$out"; bad 'strict doctor absent-index diagnostic'; }
fi

retrieval_available=0
if "$ROOT/scripts/index-memory.sh" --check "$repo" >"$out" 2>&1; then
  retrieval_available=1
  if "$ROOT/scripts/index-memory.sh" "$repo" >"$out" 2>&1 && "$ROOT/scripts/doctor.sh" --strict "$repo" >"$out" 2>&1; then
    ok 'strict doctor passes after rebuilding current index'
  else
    cat "$out"; bad 'strict doctor passes after rebuilding current index'
  fi
else
  ok 'optional FTS5 dependency may be unavailable on a runner'
fi

cp "$repo/.ai/INDEX.md" "$repo/index.good"
printf '%s\n' '| Broken route | `docs/does-not-exist.md` |' >> "$repo/.ai/INDEX.md"
if "$ROOT/scripts/doctor.sh" "$repo" >"$out" 2>&1; then
  bad 'doctor rejects broken canonical route'
else
  grep -q 'canonical memory validates' "$out" && ok 'doctor rejects broken canonical route' || { cat "$out"; bad 'doctor broken-route diagnostic'; }
fi
if "$ROOT/scripts/checkpoint.sh" "$repo" >"$out" 2>&1; then
  bad 'checkpoint stops on broken canonical route'
else
  grep -q 'doctor gate failed' "$out" && ok 'checkpoint stops on broken canonical route' || { cat "$out"; bad 'checkpoint broken-route diagnostic'; }
fi
mv "$repo/index.good" "$repo/.ai/INDEX.md"

change=handoff-demo
mkdir -p "$repo/.ai/changes/$change"
cp "$repo/.ai/changes/_template"/*.md "$repo/.ai/changes/$change/"
sed "s/Active change: \*\*none\*\*/Active change: **$change**/" "$repo/.ai/NOW.md" > "$repo/now.tmp" && mv "$repo/now.tmp" "$repo/.ai/NOW.md"
sed "s#<active-change>#$change#" "$repo/.ai/INDEX.md" > "$repo/index.tmp" && mv "$repo/index.tmp" "$repo/.ai/INDEX.md"
git -C "$repo" add .
git -C "$repo" commit -qm active

sed 's/`TODO`/`DONE`/g; s/`IN_PROGRESS`/`DONE`/g' "$repo/.ai/changes/$change/tasks.md" > "$repo/tasks.tmp" && mv "$repo/tasks.tmp" "$repo/.ai/changes/$change/tasks.md"
if "$ROOT/scripts/archive-change.sh" "$repo" "$change" >"$out" 2>&1; then
  ok 'completed active change archives through lifecycle helper'
else
  cat "$out"; bad 'completed active change archives through lifecycle helper'
fi
git -C "$repo" add -A
git -C "$repo" commit -qm archived

if (( retrieval_available )); then
  if "$ROOT/scripts/index-memory.sh" "$repo" >"$out" 2>&1 && "$ROOT/scripts/doctor.sh" --strict "$repo" >"$out" 2>&1; then
    ok 'end-to-end archived project passes strict handoff gate'
  else
    cat "$out"; bad 'end-to-end archived project passes strict handoff gate'
  fi
else
  if "$ROOT/scripts/doctor.sh" "$repo" >"$out" 2>&1; then
    ok 'end-to-end archived project passes default handoff gate without optional retrieval'
  else
    cat "$out"; bad 'end-to-end archived project passes default handoff gate without optional retrieval'
  fi
fi
[[ -d "$repo/.ai/archive/changes/$change" && ! -d "$repo/.ai/changes/$change" ]] \
  && ok 'end-to-end archive leaves active area clear' \
  || bad 'end-to-end archive leaves active area clear'

(( fail == 0 )) && { echo 'handoff gate tests passed'; exit 0; }
echo 'handoff gate tests failed'; exit 1
