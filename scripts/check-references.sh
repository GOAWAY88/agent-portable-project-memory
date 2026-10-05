#!/usr/bin/env bash
# Check current APMF Markdown for missing local routes and stale active-change paths.
# Historical .ai/archive/ content is intentionally excluded from this scan.
set -u

ROOT=${1:-.}
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "references: target does not exist: ${1:-.}" >&2; exit 2; }
if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "references: target is not a Git repository: $ROOT" >&2
  exit 2
fi
for required in "$ROOT/.ai/NOW.md" "$ROOT/.ai/INDEX.md" "$ROOT/.ai/knowledge" "$ROOT/.ai/decisions"; do
  [[ -e "$required" ]] || { echo "references: missing ${required#$ROOT/}" >&2; exit 1; }
done

fail=0
error() { echo "ERROR: $*" >&2; fail=1; }

is_candidate() {
  case "$1" in
    .ai/*|./.ai/*|AGENTS.md|README.md|ABOUT.md|CHANGELOG.md|docs/*|spec/*|scripts/*|tests/*|template/*) return 0;;
    *) return 1;;
  esac
}

check_route() {
  local source=$1 raw=$2 path archive_path
  path=${raw#\`}; path=${path%\`}
  path=${path#\](}; path=${path%)}
  path=${path%%#*}; path=${path%%\?*}
  [[ -n "$path" ]] || return 0
  [[ "$path" != *"<"* && "$path" != *">"* && "$path" != *" "* && "$path" != *"*"* ]] || return 0
  case "$path" in http://*|https://*|mailto:*|\#*) return 0;; esac
  is_candidate "$path" || return 0
  path=${path#./}
  if [[ -e "$ROOT/$path" ]]; then return 0; fi
  case "$path" in
    .ai/changes/*)
      archive_path=".ai/archive/changes/${path#.ai/changes/}"
      if [[ -e "$ROOT/$archive_path" ]]; then
        error "stale active-change reference in ${source#$ROOT/}: $path (archived at $archive_path)"
      else
        error "missing local reference in ${source#$ROOT/}: $path"
      fi;;
    *) error "missing local reference in ${source#$ROOT/}: $path";;
  esac
}

scan_file() {
  local file=$1 line token
  while IFS= read -r line || [[ -n "$line" ]]; do
    while IFS= read -r token; do check_route "$file" "$token"; done < <(printf '%s\n' "$line" | grep -oE '`[^`]+`' || true)
    while IFS= read -r token; do check_route "$file" "$token"; done < <(printf '%s\n' "$line" | grep -oE '\]\([^)]+\)' || true)
  done < "$file"
}

files=("$ROOT/.ai/NOW.md" "$ROOT/.ai/INDEX.md")
shopt -s nullglob
for file in "$ROOT"/.ai/knowledge/*.md; do files+=("$file"); done
for file in "$ROOT"/.ai/decisions/*.md; do
  [[ "$(basename "$file")" == "README.md" || "$(basename "$file")" == "ADR-TEMPLATE.md" ]] || files+=("$file")
done
shopt -u nullglob

for file in "${files[@]}"; do scan_file "$file"; done

if (( fail )); then
  echo "references: FAILED" >&2
  exit 1
fi
echo "references: OK ($ROOT; ${#files[@]} current Markdown files)"
