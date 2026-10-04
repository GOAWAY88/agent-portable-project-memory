#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0
ok() { echo "ok - $1"; }
bad() { echo "not ok - $1"; fail=1; }
OUT=$(mktemp)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp" "$OUT"' EXIT

new_repo() {
  local repo=$1
  mkdir -p "$repo"; git -C "$repo" init -q
  git -C "$repo" config user.email test@example.invalid
  git -C "$repo" config user.name test
  "$ROOT/scripts/init.sh" "$repo" >/dev/null
}

make_active() {
  local repo=$1 name=${2:-demo-change}
  mkdir -p "$repo/.ai/changes/$name"
  cp "$repo/.ai/changes/_template/"*.md "$repo/.ai/changes/$name/"
  sed "s/Active change: \*\*none\*\*/Active change: **$name**/" "$repo/.ai/NOW.md" > "$repo/NOW.tmp" && mv "$repo/NOW.tmp" "$repo/.ai/NOW.md"
  sed "s#<active-change>#$name#" "$repo/.ai/INDEX.md" > "$repo/INDEX.tmp" && mv "$repo/INDEX.tmp" "$repo/.ai/INDEX.md"
  sed 's/YYYY-MM-DD/2026-10-04/g; s/`TODO`/`DONE`/g' "$repo/.ai/changes/$name/tasks.md" > "$repo/tasks.tmp" && mv "$repo/tasks.tmp" "$repo/.ai/changes/$name/tasks.md"
  printf '%s\n' '---' 'id: ADR-0001-demo' 'status: accepted' 'created: 2026-10-04' 'updated: 2026-10-04' 'verified_at_commit: unknown' 'supersedes: null' 'superseded_by: null' "evidence: .ai/changes/$name/evidence.md" '---' '# ADR-0001-demo: Demo decision' ' ' '## Context' ' ' '## Decision' ' ' '## Consequences' ' ' '## Alternatives considered' ' ' '## Evidence and provenance' > "$repo/.ai/decisions/ADR-0001-demo.md"
  git -C "$repo" add .
  git -C "$repo" commit -qm fixture
}

expect_fail() {
  local label=$1 pattern=$2
  shift 2
  if "$@" >"$OUT" 2>&1; then
    bad "$label (unexpected success)"
  elif grep -q "$pattern" "$OUT"; then
    ok "$label"
  else
    cat "$OUT"; bad "$label (wrong diagnostic)"
  fi
}

repo="$tmp/valid"
new_repo "$repo"
make_active "$repo"
before_now=$(sha256sum "$repo/.ai/NOW.md" | cut -d' ' -f1)
if "$ROOT/scripts/archive-change.sh" --check "$repo" demo-change >"$OUT" 2>&1; then
  ok 'archive check preflight succeeds without writing'
else
  cat "$OUT"; bad 'archive check preflight succeeds without writing'
fi
[[ -d "$repo/.ai/changes/demo-change" && ! -e "$repo/.ai/archive/changes/demo-change" ]] \
  && ok 'archive check leaves source and destination unchanged' \
  || bad 'archive check leaves source and destination unchanged'
[[ "$before_now" == "$(sha256sum "$repo/.ai/NOW.md" | cut -d' ' -f1)" ]] \
  && ok 'archive check does not write NOW' \
  || bad 'archive check does not write NOW'

if "$ROOT/scripts/archive-change.sh" "$repo" demo-change >"$OUT" 2>&1; then
  ok 'completed change archives successfully'
else
  cat "$OUT"; bad 'completed change archives successfully'
fi
[[ ! -d "$repo/.ai/changes/demo-change" && -d "$repo/.ai/archive/changes/demo-change" ]] \
  && ok 'archive moves the complete change directory' \
  || bad 'archive moves the complete change directory'
grep -q '^Active change: \*\*none\*\*' "$repo/.ai/NOW.md" && ok 'archive clears NOW active change' || bad 'archive clears NOW active change'
grep -qF '| Current work | No active change; see `.ai/NOW.md` |' "$repo/.ai/INDEX.md" && ok 'archive repairs INDEX current-work route' || bad 'archive repairs INDEX current-work route'
grep -qF '.ai/archive/changes/demo-change/evidence.md' "$repo/.ai/decisions/ADR-0001-demo.md" && ok 'archive repairs ADR evidence route' || bad 'archive repairs ADR evidence route'
if "$ROOT/scripts/validate.sh" "$repo" >"$OUT" 2>&1; then ok 'archived project validates'; else cat "$OUT"; bad 'archived project validates'; fi
expect_fail 'repeated archive is rejected' 'destination already exists' "$ROOT/scripts/archive-change.sh" "$repo" demo-change

incomplete="$tmp/incomplete"
new_repo "$incomplete"
make_active "$incomplete"
sed 's/`DONE`/`TODO`/' "$incomplete/.ai/changes/demo-change/tasks.md" > "$incomplete/tasks.tmp" && mv "$incomplete/tasks.tmp" "$incomplete/.ai/changes/demo-change/tasks.md"
expect_fail 'incomplete change is rejected' 'task status is not DONE' "$ROOT/scripts/archive-change.sh" "$incomplete" demo-change
[[ -d "$incomplete/.ai/changes/demo-change" && ! -e "$incomplete/.ai/archive/changes/demo-change" ]] && ok 'incomplete archive makes no move' || bad 'incomplete archive makes no move'

conflict="$tmp/conflict"
new_repo "$conflict"
make_active "$conflict"
mkdir -p "$conflict/.ai/archive/changes/demo-change"
expect_fail 'existing archive destination is rejected' 'destination already exists' "$ROOT/scripts/archive-change.sh" "$conflict" demo-change
[[ -d "$conflict/.ai/changes/demo-change" ]] && ok 'destination conflict preserves source' || bad 'destination conflict preserves source'

rollback_repo="$tmp/rollback"
new_repo "$rollback_repo"
make_active "$rollback_repo"
printf '%s\n' '| Broken | `docs/missing.md` |' >> "$rollback_repo/.ai/INDEX.md"
expect_fail 'post-update validation failure is rejected' 'post-update validation failed' "$ROOT/scripts/archive-change.sh" "$rollback_repo" demo-change
[[ -d "$rollback_repo/.ai/changes/demo-change" && ! -e "$rollback_repo/.ai/archive/changes/demo-change" ]] \
  && ok 'validation failure rolls back the move' \
  || bad 'validation failure rolls back the move'
grep -q 'Active change: \*\*demo-change\*\*' "$rollback_repo/.ai/NOW.md" && ok 'validation failure restores NOW' || bad 'validation failure restores NOW'

(( fail == 0 )) && { echo 'lifecycle closeout tests passed'; exit 0; }
echo 'lifecycle closeout tests failed'; exit 1
