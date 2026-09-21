#!/usr/bin/env bash
set -u

SOURCE_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TARGET=${1:-}
if [[ -z "$TARGET" ]]; then echo "usage: $0 /path/to/git-project" >&2; exit 2; fi
if [[ ! -d "$TARGET" ]]; then echo "init: target directory does not exist: $TARGET" >&2; exit 1; fi
TARGET=$(cd "$TARGET" && pwd)
if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "init: target is not a Git repository: $TARGET" >&2; exit 1
fi

created=0; conflicts=0
copy_if_missing() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then echo "CONFLICT (preserved): ${dst#$TARGET/}"; conflicts=$((conflicts+1)); return; fi
  mkdir -p "$(dirname "$dst")"; cp -R "$src" "$dst"; echo "CREATED: ${dst#$TARGET/}"; created=$((created+1))
}

ignore_block='# APPM derived/local memory infrastructure
.ai/.cache/
.ai/runtime/
.ai/index/*.db
.ai/index/*.db-*
.ai/index/*.sqlite
.ai/index/*.sqlite3
.ai/local/'
if [[ ! -f "$TARGET/.gitignore" ]]; then
  printf '%s\n' "$ignore_block" > "$TARGET/.gitignore"
  echo "CREATED: .gitignore (APPM runtime rules)"; created=$((created+1))
elif ! grep -qF '# APPM derived/local memory infrastructure' "$TARGET/.gitignore"; then
  printf '\n%s\n' "$ignore_block" >> "$TARGET/.gitignore"
  echo "UPDATED: .gitignore (appended APPM runtime rules)"; created=$((created+1))
else
  echo "OK: .gitignore already contains APPM runtime rules"
fi

if [[ -e "$TARGET/AGENTS.md" ]]; then
  echo "CONFLICT (preserved): AGENTS.md exists; manually merge the APPM entry protocol from template/AGENTS.md"; conflicts=$((conflicts+1))
else
  cp "$SOURCE_ROOT/template/AGENTS.md" "$TARGET/AGENTS.md"; echo "CREATED: AGENTS.md"; created=$((created+1))
fi

mkdir -p "$TARGET/.ai"
while IFS= read -r -d '' src; do
  rel=${src#"$SOURCE_ROOT/template/.ai/"}; dst="$TARGET/.ai/$rel"
  if [[ -d "$src" ]]; then mkdir -p "$dst"; continue; fi
  copy_if_missing "$src" "$dst"
done < <(find "$SOURCE_ROOT/template/.ai" -type f -print0)

echo "init: created $created item(s); conflicts $conflicts"
if (( conflicts )); then echo "init: no existing files were overwritten; review conflicts before committing."; fi
