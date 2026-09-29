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

# Regression: archival of the last change must not leave .ai/changes/ untracked and empty,
# because Git drops empty directories and validate.sh requires the path to exist.
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  [[ -n "$(git -C "$ROOT" ls-files -- .ai/changes/)" ]] \
    && ok '.ai/changes has tracked placeholder content' \
    || bad '.ai/changes has tracked placeholder content'
fi

# End-to-end lifecycle regression: init -> active change -> all tasks DONE -> archive
# must leave the generated project valid, with .ai/changes/ still present.
lifecycle="$tmp/lifecycle"
mkdir "$lifecycle"; git -C "$lifecycle" init -q; git -C "$lifecycle" config user.email test@example.invalid; git -C "$lifecycle" config user.name test
if "$ROOT/scripts/init.sh" "$lifecycle" >"$OUT" 2>&1; then
  mkdir -p "$lifecycle/.ai/changes/lifecycle-demo"
  cp "$lifecycle/.ai/changes/_template/"*.md "$lifecycle/.ai/changes/lifecycle-demo/"
  sed 's/Active change: \*\*none\*\*/Active change: **lifecycle-demo**/' "$lifecycle/.ai/NOW.md" > "$lifecycle/NOW.tmp" && mv "$lifecycle/NOW.tmp" "$lifecycle/.ai/NOW.md"
  git -C "$lifecycle" add .; git -C "$lifecycle" commit -qm active
  sed -e 's/`TODO`/`DONE`/g' -e 's/`IN_PROGRESS`/`DONE`/g' "$lifecycle/.ai/changes/lifecycle-demo/tasks.md" > "$lifecycle/tasks.tmp" && mv "$lifecycle/tasks.tmp" "$lifecycle/.ai/changes/lifecycle-demo/tasks.md"
  mkdir -p "$lifecycle/.ai/archive/changes"
  git -C "$lifecycle" mv -q .ai/changes/lifecycle-demo .ai/archive/changes/lifecycle-demo 2>/dev/null \
    || mv "$lifecycle/.ai/changes/lifecycle-demo" "$lifecycle/.ai/archive/changes/lifecycle-demo"
  sed 's/Active change: \*\*lifecycle-demo\*\*/Active change: **none**/' "$lifecycle/.ai/NOW.md" > "$lifecycle/NOW.tmp" && mv "$lifecycle/NOW.tmp" "$lifecycle/.ai/NOW.md"
  git -C "$lifecycle" add -A; git -C "$lifecycle" commit -qm archived
  [[ -d "$lifecycle/.ai/changes" ]] && ok 'archival keeps .ai/changes directory' || bad 'archival keeps .ai/changes directory'
  [[ -n "$(git -C "$lifecycle" ls-files -- .ai/changes/)" ]] \
    && ok 'archival keeps .ai/changes tracked content' \
    || bad 'archival keeps .ai/changes tracked content'
  check 'project validates after archiving last change' "$ROOT/scripts/validate.sh" "$lifecycle"
else
  cat "$OUT"; bad 'lifecycle fixture init failed'
fi

# V0.3 profiles: default software behavior, paper overlay, and manifest enforcement.
[[ -f "$tmp/project/.ai/profile.md" ]] && ok 'default init installs profile manifest' || bad 'default init installs profile manifest'
grep -q 'name: software' "$tmp/project/.ai/profile.md" 2>/dev/null && ok 'default profile is software' || bad 'default profile is software'
[[ -f "$tmp/project/.ai/knowledge/ARCHITECTURE.md" ]] && ok 'software profile seeds ARCHITECTURE.md' || bad 'software profile seeds ARCHITECTURE.md'

paper="$tmp/paper"
mkdir "$paper"; git -C "$paper" init -q; git -C "$paper" config user.email test@example.invalid; git -C "$paper" config user.name test
check 'init with paper profile succeeds' "$ROOT/scripts/init.sh" --profile paper "$paper"
check 'paper project validates' "$ROOT/scripts/validate.sh" "$paper"
for k in RESEARCH_QUESTIONS.md METHODS.md EXPERIMENTS.md; do
  [[ -f "$paper/.ai/knowledge/$k" ]] && ok "paper profile seeds $k" || bad "paper profile seeds $k"
done
[[ ! -f "$paper/.ai/knowledge/ARCHITECTURE.md" ]] && ok 'paper profile omits software-only seeds' || bad 'paper profile omits software-only seeds'

if "$ROOT/scripts/init.sh" --profile nosuch "$tmp/nosuch" >"$OUT" 2>&1; then
  bad 'unknown profile is rejected'
elif grep -q "unknown profile" "$OUT"; then
  ok 'unknown profile is rejected'
else
  cat "$OUT"; bad 'unknown profile is rejected (wrong diagnostic)'
fi

rm "$paper/.ai/knowledge/METHODS.md"
if "$ROOT/scripts/validate.sh" "$paper" >"$OUT" 2>&1; then
  bad 'missing manifest-required knowledge is rejected'
elif grep -q 'missing .ai/knowledge/METHODS.md' "$OUT"; then
  ok 'missing manifest-required knowledge is rejected'
else
  cat "$OUT"; bad 'missing manifest-required knowledge is rejected (wrong diagnostic)'
fi

sed 's/name: paper/name: Bad Name/' "$paper/.ai/profile.md" > "$paper/profile.tmp" && mv "$paper/profile.tmp" "$paper/.ai/profile.md"
if "$ROOT/scripts/validate.sh" "$paper" >"$OUT" 2>&1; then
  bad 'malformed profile name is rejected'
elif grep -q 'invalid profile name' "$OUT"; then
  ok 'malformed profile name is rejected'
else
  cat "$OUT"; bad 'malformed profile name is rejected (wrong diagnostic)'
fi

# Backward compatibility: a project without .ai/profile.md falls back to software defaults.
legacy="$tmp/legacy"
mkdir "$legacy"; git -C "$legacy" init -q; git -C "$legacy" config user.email test@example.invalid; git -C "$legacy" config user.name test
"$ROOT/scripts/init.sh" "$legacy" >"$OUT" 2>&1
rm "$legacy/.ai/profile.md"
check 'manifest-less project still validates via software fallback' "$ROOT/scripts/validate.sh" "$legacy"
rm "$legacy/.ai/knowledge/COMMANDS.md"
if "$ROOT/scripts/validate.sh" "$legacy" >"$OUT" 2>&1; then
  bad 'fallback still enforces software defaults'
elif grep -q 'missing .ai/knowledge/COMMANDS.md' "$OUT"; then
  ok 'fallback still enforces software defaults'
else
  cat "$OUT"; bad 'fallback still enforces software defaults (wrong diagnostic)'
fi

(( fail == 0 )) && { echo 'all structure tests passed'; exit 0; }
echo 'structure tests failed'; exit 1
