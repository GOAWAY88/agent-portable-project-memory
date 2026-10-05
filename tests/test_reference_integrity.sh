#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
tmp=$(mktemp -d)
out=$(mktemp)
trap 'rm -rf "$tmp" "$out"' EXIT

new_repo() {
  local repo=$1
  mkdir -p "$repo"; git -C "$repo" init -q
  git -C "$repo" config user.email test@example.invalid
  git -C "$repo" config user.name test
  "$ROOT/scripts/init.sh" "$repo" >/dev/null
}

repo="$tmp/project"
new_repo "$repo"
mkdir -p "$repo/.ai/changes/demo-change" "$repo/.ai/decisions"
cp "$repo/.ai/changes/_template"/*.md "$repo/.ai/changes/demo-change/"
sed 's/Active change: \*\*none\*\*/Active change: **demo-change**/' "$repo/.ai/NOW.md" > "$repo/now.tmp" && mv "$repo/now.tmp" "$repo/.ai/NOW.md"
sed 's#<active-change>#demo-change#' "$repo/.ai/INDEX.md" > "$repo/index.tmp" && mv "$repo/index.tmp" "$repo/.ai/INDEX.md"
printf '%s\n' '---' 'id: ADR-0001-demo' 'status: accepted' 'created: 2026-10-05' 'updated: 2026-10-05' 'verified_at_commit: unknown' 'supersedes: null' 'superseded_by: null' 'evidence: .ai/changes/demo-change/evidence.md' '---' '# ADR-0001-demo: Demo' > "$repo/.ai/decisions/ADR-0001-demo.md"
git -C "$repo" add .
git -C "$repo" commit -qm fixture

if "$ROOT/scripts/check-references.sh" "$repo" >"$out" 2>&1; then
  ok 'valid current routes pass'
else
  cat "$out"; bad 'valid current routes pass'
fi

mkdir -p "$repo/.ai/archive/changes/demo-change"
mv "$repo/.ai/changes/demo-change" "$repo/.ai/archive/changes/demo-change/"
if "$ROOT/scripts/check-references.sh" "$repo" >"$out" 2>&1; then
  bad 'stale active route is rejected'
else
  grep -q 'stale active-change reference' "$out" && ok 'stale active route is rejected' || { cat "$out"; bad 'stale active route diagnostic'; }
fi

sed -i.bak 's#\.ai/changes/demo-change/#.ai/archive/changes/demo-change/#g' "$repo/.ai/NOW.md" "$repo/.ai/INDEX.md" "$repo/.ai/decisions/ADR-0001-demo.md"
rm -f "$repo/.ai/NOW.md.bak" "$repo/.ai/INDEX.md.bak" "$repo/.ai/decisions/ADR-0001-demo.md.bak"
sed -i.bak 's/Active change: \*\*demo-change\*\*/Active change: **none**/' "$repo/.ai/NOW.md" && rm -f "$repo/.ai/NOW.md.bak"
if "$ROOT/scripts/check-references.sh" "$repo" >"$out" 2>&1; then
  ok 'archived route passes after explicit repair'
else
  cat "$out"; bad 'archived route passes after explicit repair'
fi

printf '%s\n' '[external documentation](https://example.com)' >> "$repo/.ai/knowledge/PROJECT.md"
printf '%s\n' '| Missing | `docs/no-such-file.md` |' >> "$repo/.ai/INDEX.md"
if "$ROOT/scripts/check-references.sh" "$repo" >"$out" 2>&1; then
  bad 'missing current route is rejected'
else
  grep -q 'missing local reference' "$out" && ok 'missing current route is rejected' || { cat "$out"; bad 'missing route diagnostic'; }
fi

sed -i.bak 's#evidence: .ai/archive/changes/demo-change/evidence.md#evidence: .ai/archive/changes/no-such-evidence.md#' "$repo/.ai/decisions/ADR-0001-demo.md" && rm -f "$repo/.ai/decisions/ADR-0001-demo.md.bak"
if "$ROOT/scripts/validate.sh" "$repo" >"$out" 2>&1; then
  bad 'missing ADR evidence path is rejected'
else
  grep -q 'ADR evidence path does not exist' "$out" && ok 'missing ADR evidence path is rejected' || { cat "$out"; bad 'missing ADR evidence diagnostic'; }
fi

(( fail == 0 )) && { echo 'reference integrity tests passed'; exit 0; }
echo 'reference integrity tests failed'; exit 1
