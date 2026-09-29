#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
OUT=$(mktemp)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp" "$OUT"' EXIT

make_repo() {
  local repo=$1
  mkdir -p "$repo"; git -C "$repo" init -q
  git -C "$repo" config user.email test@example.invalid; git -C "$repo" config user.name test
  "$ROOT/scripts/init.sh" "$repo" >/dev/null
  mkdir -p "$repo/.ai/changes/demo-change"
  cp "$repo/.ai/changes/_template/"*.md "$repo/.ai/changes/demo-change/"
  sed 's/Active change: \*\*none\*\*/Active change: **demo-change**/' "$repo/.ai/NOW.md" > "$repo/.ai/NOW.md.tmp" && mv "$repo/.ai/NOW.md.tmp" "$repo/.ai/NOW.md"
  git -C "$repo" add .; git -C "$repo" commit -qm fixture
}
expect_fail() {
  local label=$1 pattern=$2 repo=$3
  if "$ROOT/scripts/validate.sh" "$repo" >"$OUT" 2>&1; then
    bad "$label (unexpected success)"
  elif grep -q "$pattern" "$OUT"; then
    ok "$label"
  else
    cat "$OUT"; bad "$label (wrong diagnostic)"
  fi
}

base="$tmp/base"; make_repo "$base"
if "$ROOT/scripts/validate.sh" "$base" >"$OUT" 2>&1; then ok 'valid active fixture passes'; else cat "$OUT"; bad 'valid active fixture passes'; fi

case_dir="$tmp/broken-index"; git clone -q "$base" "$case_dir"
printf '| Broken | `docs/does-not-exist.md` |\n' >> "$case_dir/.ai/INDEX.md"
expect_fail 'broken INDEX path is rejected' 'INDEX path does not exist' "$case_dir"

case_dir="$tmp/invalid-status"; git clone -q "$base" "$case_dir"
sed 's/`TODO`/`INVALID`/' "$case_dir/.ai/changes/demo-change/tasks.md" > "$case_dir/tasks.tmp" && mv "$case_dir/tasks.tmp" "$case_dir/.ai/changes/demo-change/tasks.md"
expect_fail 'invalid task status is rejected' 'invalid task status' "$case_dir"

case_dir="$tmp/missing-active"; git clone -q "$base" "$case_dir"
sed 's/Active change: \*\*demo-change\*\*/Active change: **missing-change**/' "$case_dir/.ai/NOW.md" > "$case_dir/NOW.tmp" && mv "$case_dir/NOW.tmp" "$case_dir/.ai/NOW.md"
expect_fail 'missing active change is rejected' 'NOW active change does not exist' "$case_dir"

case_dir="$tmp/invalid-knowledge-status"; git clone -q "$base" "$case_dir"
sed 's/status: current/status: INVALID/' "$case_dir/.ai/knowledge/PROJECT.md" > "$case_dir/PROJECT.tmp" && mv "$case_dir/PROJECT.tmp" "$case_dir/.ai/knowledge/PROJECT.md"
expect_fail 'invalid knowledge status is rejected' 'invalid knowledge status' "$case_dir"

case_dir="$tmp/expired-commit"; git clone -q "$base" "$case_dir"
sed 's/verified_at_commit: unknown/verified_at_commit: deadbeef/' "$case_dir/.ai/NOW.md" > "$case_dir/NOW.tmp" && mv "$case_dir/NOW.tmp" "$case_dir/.ai/NOW.md"
expect_fail 'unresolvable commit is rejected' 'unresolvable verified_at_commit' "$case_dir"

case_dir="$tmp/missing-evidence"; git clone -q "$base" "$case_dir"
rm "$case_dir/.ai/changes/demo-change/evidence.md"
expect_fail 'missing evidence artifact is rejected' 'missing .ai/changes/demo-change/evidence.md' "$case_dir"

case_dir="$tmp/completed-active"; git clone -q "$base" "$case_dir"
sed -e 's/`IN_PROGRESS`/`DONE`/' -e 's/`TODO`/`DONE`/g' "$case_dir/.ai/changes/demo-change/tasks.md" > "$case_dir/tasks.tmp" && mv "$case_dir/tasks.tmp" "$case_dir/.ai/changes/demo-change/tasks.md"
expect_fail 'completed active change is rejected' 'completed change remains active' "$case_dir"

case_dir="$tmp/missing-now-field"; git clone -q "$base" "$case_dir"
sed '/^Blockers:/d' "$case_dir/.ai/NOW.md" > "$case_dir/NOW.tmp" && mv "$case_dir/NOW.tmp" "$case_dir/.ai/NOW.md"
expect_fail 'missing NOW field is rejected' "missing NOW field 'Blockers'" "$case_dir"

case_dir="$tmp/bad-adr"; git clone -q "$base" "$case_dir"
printf '%s\n' '---' 'id: ADR-0001-test' 'status: accepted' 'created: 2026-09-24' 'updated: 2026-09-24' 'verified_at_commit: unknown' 'supersedes: null' 'superseded_by: null' '---' '# ADR-0001-test: Missing evidence' > "$case_dir/.ai/decisions/ADR-0001-test.md"
expect_fail 'accepted ADR without evidence is rejected' "missing front-matter 'evidence'" "$case_dir"

case_dir="$tmp/bad-adr-name"; git clone -q "$base" "$case_dir"
printf '# malformed\n' > "$case_dir/.ai/decisions/ADR-bad-name.md"
expect_fail 'invalid ADR name is rejected' 'invalid ADR filename' "$case_dir"

if (( fail == 0 )); then echo 'memory integrity tests passed'; exit 0; fi
echo 'memory integrity tests failed'; exit 1
