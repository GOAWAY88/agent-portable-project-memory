#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }

if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP - optional retrieval tests require python3"
  exit 0
fi

tmp=$(mktemp -d)
out=$(mktemp)
trap 'rm -rf "$tmp" "$out"' EXIT
repo="$tmp/project"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email test@example.invalid
git -C "$repo" config user.name test
"$ROOT/scripts/init.sh" "$repo" >/dev/null
printf '%s\n' '# Extra retrieval marker: alphaprovenance' > "$repo/.ai/knowledge/EXTRA.md"
git -C "$repo" add .
git -C "$repo" commit -qm fixture

if "$ROOT/scripts/index-memory.sh" --check "$repo" >"$out" 2>&1; then
  ok 'retrieval preflight succeeds without writing'
else
  cat "$out"; bad 'retrieval preflight succeeds without writing'
fi
[[ ! -e "$repo/.ai/index/memory.sqlite3" ]] && ok 'preflight leaves index absent' || bad 'preflight leaves index absent'

if "$ROOT/scripts/index-memory.sh" "$repo" >"$out" 2>&1; then
  ok 'retrieval index builds'
else
  cat "$out"; bad 'retrieval index builds'
fi
[[ -f "$repo/.ai/index/memory.sqlite3" ]] && ok 'derived database is created' || bad 'derived database is created'

if "$ROOT/scripts/index-memory.sh" --query alphaprovenance "$repo" >"$out" 2>&1 && grep -qF '.ai/knowledge/EXTRA.md' "$out"; then
  ok 'BM25 query returns canonical source path'
else
  cat "$out"; bad 'BM25 query returns canonical source path'
fi
first_result=$(cat "$out")
if "$ROOT/scripts/index-memory.sh" "$repo" >"$out" 2>&1 && "$ROOT/scripts/index-memory.sh" --query alphaprovenance "$repo" >"$out" 2>&1 && [[ "$first_result" == "$(cat "$out")" ]]; then
  ok 'rebuilding the same source tree is query-idempotent'
else
  cat "$out"; bad 'rebuilding the same source tree is query-idempotent'
fi

before=$(sha256sum "$repo/.ai/index/memory.sqlite3" | cut -d' ' -f1)
if "$ROOT/scripts/index-memory.sh" --query '"unterminated' "$repo" >"$out" 2>&1; then
  bad 'malformed query is rejected'
else
  ok 'malformed query is rejected'
fi
[[ "$before" == "$(sha256sum "$repo/.ai/index/memory.sqlite3" | cut -d' ' -f1)" ]] \
  && ok 'failed query leaves derived index unchanged' \
  || bad 'failed query leaves derived index unchanged'

rm "$repo/.ai/knowledge/EXTRA.md"
printf '%s\n' '# Fresh retrieval marker: betarebuild' > "$repo/.ai/knowledge/REBUILT.md"
if "$ROOT/scripts/index-memory.sh" "$repo" >"$out" 2>&1; then
  ok 'rebuild succeeds after source change'
else
  cat "$out"; bad 'rebuild succeeds after source change'
fi
if "$ROOT/scripts/index-memory.sh" --query betarebuild "$repo" >"$out" 2>&1 && grep -qF '.ai/knowledge/REBUILT.md' "$out"; then
  ok 'rebuild indexes newly added canonical Markdown'
else
  cat "$out"; bad 'rebuild indexes newly added canonical Markdown'
fi
if "$ROOT/scripts/index-memory.sh" --query alphaprovenance "$repo" >"$out" 2>&1 && [[ ! -s "$out" ]]; then
  ok 'rebuild removes deleted canonical content'
else
  cat "$out"; bad 'rebuild removes deleted canonical content'
fi

if git -C "$repo" check-ignore -q "$repo/.ai/index/memory.sqlite3"; then
  ok 'derived database is ignored by Git'
else
  cat "$repo/.gitignore"; bad 'derived database is ignored by Git'
fi

(( fail == 0 )) && { echo 'retrieval index tests passed'; exit 0; }
echo 'retrieval index tests failed'; exit 1
