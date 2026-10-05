#!/usr/bin/env bash
# Read-only APMF handoff health gate. Warnings become failures with --strict.
set -u

STRICT=0
ROOT=
while (( $# )); do
  case "$1" in
    --strict) STRICT=1; shift;;
    -h|--help)
      echo "usage: $0 [--strict] [project]"
      echo "  runs read-only structural, reference, provenance, Git, and optional-index checks"
      echo "  --strict treats warnings as failures"
      exit 0;;
    *)
      if [[ -n "$ROOT" ]]; then echo "doctor: unexpected extra argument: $1" >&2; exit 2; fi
      ROOT=$1; shift;;
  esac
done

ROOT=${ROOT:-.}
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "doctor: target does not exist: ${ROOT:-.}" >&2; exit 2; }
if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "doctor: target is not a Git repository: $ROOT" >&2
  exit 2
fi

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
out=$(mktemp "${TMPDIR:-/tmp}/apmf-doctor.XXXXXX") || { echo "doctor: cannot create temporary output" >&2; exit 1; }
trap 'rm -f "$out"' EXIT
errors=0
warnings=0

pass() { echo "PASS: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; warnings=$((warnings + 1)); }
fail() { echo "FAIL: $*" >&2; errors=$((errors + 1)); }

run_gate() {
  local label=$1
  shift
  if "$@" >"$out" 2>&1; then
    pass "$label"
  else
    fail "$label"
    sed 's/^/  /' "$out" >&2
  fi
}

frontmatter_value() {
  awk -v key="$2" '
    NR == 1 { in_front = ($0 == "---"); next }
    in_front && $0 == "---" { exit }
    in_front && index($0, key ":") == 1 { sub("^[^:]*:[[:space:]]*", ""); print; exit }
  ' "$1"
}

echo "Doctor for $ROOT"
run_gate "canonical memory validates" "$SCRIPT_ROOT/validate.sh" "$ROOT"
run_gate "current memory references resolve" "$SCRIPT_ROOT/check-references.sh" "$ROOT"
run_gate "provenance placeholders are closed" "$SCRIPT_ROOT/close-provenance.sh" --check "$ROOT"

head_sha=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || true)
branch=$(git -C "$ROOT" branch --show-current 2>/dev/null || true)
if [[ -n "$head_sha" ]]; then pass "Git HEAD exists (${head_sha:0:7})"; else fail "Git repository has no commit"; fi

if [[ -f "$ROOT/.ai/NOW.md" ]]; then
  declared_branch=$(frontmatter_value "$ROOT/.ai/NOW.md" branch)
  if [[ -n "$branch" && "$declared_branch" == "$branch" ]]; then
    pass "NOW branch matches Git ($branch)"
  else
    warn "NOW branch '${declared_branch:-missing}' differs from Git branch '${branch:-detached}'"
  fi

  blockers=$(sed -n 's/^Blockers:[[:space:]]*\*\*\(.*\)\*\*[[:space:]]*$/\1/p' "$ROOT/.ai/NOW.md" | head -1)
  case "$blockers" in
    "none known"|none|"") pass "NOW reports no blockers";;
    *) warn "NOW reports blockers: $blockers";;
  esac

  active=$(sed -n 's/^Active change:[[:space:]]*\*\*\([^*]*\)\*\*.*$/\1/p' "$ROOT/.ai/NOW.md" | head -1)
  if [[ "$active" == "none" ]]; then
    info "active change: none"
  elif [[ -n "$active" && -f "$ROOT/.ai/changes/$active/tasks.md" ]]; then
    done_count=$(grep -oE '`DONE`' "$ROOT/.ai/changes/$active/tasks.md" 2>/dev/null | wc -l | tr -d ' ')
    open_count=$(grep -oE '`(TODO|IN_PROGRESS|BLOCKED)`' "$ROOT/.ai/changes/$active/tasks.md" 2>/dev/null | wc -l | tr -d ' ')
    info "active change: $active ($done_count done, $open_count open)"
  else
    fail "NOW active change cannot be summarized: ${active:-missing}"
  fi
fi

dirty=$(git -C "$ROOT" status --porcelain 2>/dev/null || true)
if [[ -z "$dirty" ]]; then
  pass "Git worktree is clean"
else
  dirty_count=$(printf '%s\n' "$dirty" | wc -l | tr -d ' ')
  warn "Git worktree has $dirty_count changed path(s)"
fi

index_db="$ROOT/.ai/index/memory.sqlite3"
if [[ ! -f "$index_db" ]]; then
  warn "optional retrieval index is absent"
else
  python_bin=${PYTHON:-python3}
  if ! command -v "$python_bin" >/dev/null 2>&1; then
    warn "optional retrieval index exists but python3 is unavailable for freshness inspection"
  elif metadata=$("$python_bin" - "$index_db" <<'PY'
import sqlite3
import sys

path = sys.argv[1]
connection = sqlite3.connect("file:{}?mode=ro".format(path), uri=True)
try:
    values = dict(connection.execute("SELECT key, value FROM metadata"))
    print("{}\t{}\t{}".format(
        values.get("schema_version", "missing"),
        values.get("generated_at_commit", "missing"),
        values.get("document_count", "missing"),
    ))
finally:
    connection.close()
PY
  ); then
    IFS=$'\t' read -r index_schema index_commit index_count <<< "$metadata"
    if [[ "$index_schema" != "1" ]]; then
      warn "optional retrieval index schema is '$index_schema', expected '1'"
    elif [[ -z "$head_sha" || "$index_commit" != "$head_sha" ]]; then
      warn "optional retrieval index is stale (built at ${index_commit:0:7}, HEAD ${head_sha:0:7})"
    else
      pass "optional retrieval index is current ($index_count documents)"
    fi
  else
    warn "optional retrieval index metadata cannot be read"
  fi
fi

if (( errors )); then
  echo "doctor: FAILED ($errors error(s), $warnings warning(s))" >&2
  exit 1
fi
if (( STRICT && warnings )); then
  echo "doctor: FAILED (strict mode: $warnings warning(s))" >&2
  exit 1
fi
echo "doctor: OK ($warnings warning(s))"
