#!/usr/bin/env bash
# Bind unresolved template provenance to the first real Git commit (or any later
# commit when a project is initialized before its first handoff). Existing
# commit values are never overwritten.
set -u

CHECK_ONLY=0
ROOT=
while (( $# )); do
  case "$1" in
    --check) CHECK_ONLY=1; shift;;
    -h|--help)
      echo "usage: $0 [--check] [project]"
      echo "  updates front-matter verified_at_commit: unknown|none|null|[commit]"
      echo "  --check reports unresolved placeholders without writing files"
      exit 0;;
    *)
      if [[ -n "$ROOT" ]]; then echo "provenance: unexpected extra argument: $1" >&2; exit 2; fi
      ROOT=$1; shift;;
  esac
done

ROOT=${ROOT:-.}
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "provenance: target does not exist: ${ROOT:-.}" >&2; exit 2; }
if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "provenance: target is not a Git repository: $ROOT" >&2
  exit 2
fi
if ! git -C "$ROOT" rev-parse --verify HEAD^{commit} >/dev/null 2>&1; then
  echo "provenance: no commit exists yet; leave template provenance unresolved" >&2
  exit 2
fi
if [[ ! -f "$ROOT/.ai/NOW.md" ]]; then
  echo "provenance: missing .ai/NOW.md; target is not an initialized APMF project" >&2
  exit 1
fi

SHA=$(git -C "$ROOT" rev-parse HEAD^{commit})
files=("$ROOT/.ai/NOW.md")
shopt -s nullglob
for file in "$ROOT"/.ai/knowledge/*.md "$ROOT"/.ai/decisions/*.md; do files+=("$file"); done
shopt -u nullglob

changed=0
for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  tmp=$(mktemp "${TMPDIR:-/tmp}/apmf-provenance.XXXXXX") || {
    echo "provenance: cannot create temporary file for ${file#$ROOT/}" >&2
    exit 1
  }
  if ! awk -v sha="$SHA" '
    NR == 1 && $0 == "---" { in_front = 1; print; next }
    in_front && $0 == "---" { in_front = 0; print; next }
    in_front && $0 ~ /^verified_at_commit:[[:space:]]*(unknown|null|none|\[commit\])[[:space:]]*$/ {
      print "verified_at_commit: " sha
      next
    }
    { print }
  ' "$file" > "$tmp"; then
    rm -f "$tmp"
    echo "provenance: failed to read ${file#$ROOT/}" >&2
    exit 1
  fi

  if cmp -s "$file" "$tmp"; then
    rm -f "$tmp"
    continue
  fi
  changed=$((changed + 1))
  if (( CHECK_ONLY )); then
    echo "NEEDS: ${file#$ROOT/} -> $SHA"
    rm -f "$tmp"
  else
    if ! mv "$tmp" "$file"; then
      rm -f "$tmp"
      echo "provenance: failed to update ${file#$ROOT/}" >&2
      exit 1
    fi
    echo "UPDATED: ${file#$ROOT/} -> $SHA"
  fi
done

if (( CHECK_ONLY )); then
  if (( changed )); then
    echo "provenance: FAILED ($changed unresolved file(s)); run without --check to close them" >&2
    exit 1
  fi
  echo "provenance: OK ($ROOT; HEAD $SHA)"
  exit 0
fi

echo "provenance: updated $changed file(s) to HEAD $SHA"
