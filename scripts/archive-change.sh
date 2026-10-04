#!/usr/bin/env bash
# Archive one completed APMF change and repair its mechanical routes.
# This helper never creates a Git commit; it either completes the filesystem
# transition and validates it, or restores the pre-operation state.
set -u

CHECK_ONLY=0
ROOT=
CHANGE=
while (( $# )); do
  case "$1" in
    --check) CHECK_ONLY=1; shift;;
    -h|--help)
      echo "usage: $0 [--check] <project> <change>"
      echo "  archives a completed .ai/changes/<change> and repairs NOW/INDEX/ADR routes"
      echo "  --check performs preflight only and makes no writes"
      exit 0;;
    *)
      if [[ -z "$ROOT" ]]; then ROOT=$1
      elif [[ -z "$CHANGE" ]]; then CHANGE=$1
      else echo "archive: unexpected extra argument: $1" >&2; exit 2
      fi
      shift;;
  esac
done

if [[ -z "$ROOT" || -z "$CHANGE" ]]; then
  echo "usage: $0 [--check] <project> <change>" >&2
  exit 2
fi
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "archive: target does not exist" >&2; exit 2; }
if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "archive: target is not a Git repository: $ROOT" >&2
  exit 2
fi
if [[ ! "$CHANGE" =~ ^[a-z0-9][a-z0-9.-]*$ ]]; then
  echo "archive: invalid change name '$CHANGE'" >&2
  exit 1
fi

NOW="$ROOT/.ai/NOW.md"
INDEX="$ROOT/.ai/INDEX.md"
SOURCE="$ROOT/.ai/changes/$CHANGE"
DEST="$ROOT/.ai/archive/changes/$CHANGE"
OLD_PATH=".ai/changes/$CHANGE/"
NEW_PATH=".ai/archive/changes/$CHANGE/"
if [[ -e "$DEST" ]]; then
  echo "archive: destination already exists: ${DEST#$ROOT/}" >&2
  exit 1
fi
for required in "$NOW" "$INDEX" "$SOURCE"; do
  [[ -e "$required" ]] || { echo "archive: missing ${required#$ROOT/}" >&2; exit 1; }
done
[[ -d "$SOURCE" ]] || { echo "archive: active change is not a directory: $CHANGE" >&2; exit 1; }

active=$(sed -n 's/^Active change:[[:space:]]*\*\*\([^*]*\)\*\*.*$/\1/p' "$NOW" | head -1)
if [[ "$active" != "$CHANGE" ]]; then
  echo "archive: NOW active change is '$active', expected '$CHANGE'" >&2
  exit 1
fi

for artifact in proposal.md design.md tasks.md evidence.md; do
  [[ -f "$SOURCE/$artifact" ]] || { echo "archive: missing .ai/changes/$CHANGE/$artifact" >&2; exit 1; }
done

statuses=$(grep -oE '`[A-Z_]+`' "$SOURCE/tasks.md" || true)
if [[ -z "$statuses" ]]; then
  echo "archive: tasks.md has no status tokens" >&2
  exit 1
fi
all_done=1
while IFS= read -r token; do
  token=${token#\`}; token=${token%\`}
  case "$token" in
    DONE) ;;
    TODO|IN_PROGRESS|BLOCKED) all_done=0; echo "archive: task status is not DONE: $token" >&2;;
    *) all_done=0; echo "archive: invalid task status: $token" >&2;;
  esac
done <<< "$statuses"
if (( ! all_done )); then exit 1; fi

index_label=
if grep -q '^| Current work |' "$INDEX"; then
  index_label='Current work'
elif grep -q '^| Current implementation |' "$INDEX"; then
  index_label='Current implementation'
else
  echo "archive: INDEX has no Current work or Current implementation row" >&2
  exit 1
fi
if ! grep -F "$OLD_PATH" "$INDEX" | grep -Eq "^\\| ${index_label} \\|"; then
  echo "archive: INDEX $index_label does not point to $OLD_PATH" >&2
  exit 1
fi

adr_files=()
shopt -s nullglob
for adr in "$ROOT"/.ai/decisions/*.md; do
  [[ "$(basename "$adr")" == "ADR-TEMPLATE.md" ]] && continue
  if grep -qF "$OLD_PATH" "$adr"; then adr_files+=("$adr"); fi
done
shopt -u nullglob

if (( CHECK_ONLY )); then
  echo "archive: READY $CHANGE"
  echo "  move: $OLD_PATH -> $NEW_PATH"
  echo "  route: NOW active change -> none; INDEX $index_label -> .ai/NOW.md"
  for adr in "${adr_files[@]}"; do echo "  evidence: ${adr#$ROOT/} ($OLD_PATH -> $NEW_PATH)"; done
  exit 0
fi

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
backup=$(mktemp -d "${TMPDIR:-/tmp}/apmf-archive.XXXXXX") || { echo "archive: cannot create rollback directory" >&2; exit 1; }
route_files=("$NOW" "$INDEX" "${adr_files[@]}")
for file in "${route_files[@]}"; do
  rel=${file#$ROOT/}
  mkdir -p "$backup/$(dirname "$rel")" || { rm -rf "$backup"; echo "archive: cannot prepare rollback" >&2; exit 1; }
  cp -p "$file" "$backup/$rel" || { rm -rf "$backup"; echo "archive: cannot back up ${file#$ROOT/}" >&2; exit 1; }
done

rollback() {
  if [[ -d "$DEST" && ! -e "$SOURCE" ]]; then mv "$DEST" "$SOURCE" || true; fi
  for file in "${route_files[@]}"; do
    rel=${file#$ROOT/}
    cp -p "$backup/$rel" "$file" || true
  done
  rm -rf "$backup"
}

mkdir -p "$(dirname "$DEST")" || { rollback; echo "archive: cannot create archive directory" >&2; exit 1; }
if ! mv "$SOURCE" "$DEST"; then
  rollback
  echo "archive: failed to move change to archive" >&2
  exit 1
fi

tmp=$(mktemp "${TMPDIR:-/tmp}/apmf-route.XXXXXX") || { rollback; echo "archive: cannot create route temporary file" >&2; exit 1; }
if ! { awk '
  /^Active change:/ { print "Active change: **none**"; next }
  /^Current task:/ { print "Current task: **No active change.**"; next }
  /^Next action:/ { print "Next action: **Create a new `.ai/changes/*` directory for the next non-trivial task.**"; next }
  { print }
' "$NOW" > "$tmp" && mv "$tmp" "$NOW"; }; then
  rm -f "$tmp"; rollback; echo "archive: failed to update NOW.md" >&2; exit 1
fi

if ! {
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "| $index_label |"* ]]; then
        printf '%s\n' "| $index_label | No active change; see \`.ai/NOW.md\` |"
    else
      printf '%s\n' "${line//$OLD_PATH/$NEW_PATH}"
    fi
  done < "$INDEX" > "$tmp" && mv "$tmp" "$INDEX"
}; then
  rm -f "$tmp"; rollback; echo "archive: failed to update INDEX.md" >&2; exit 1
fi

for adr in "${adr_files[@]}"; do
  while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "${line//$OLD_PATH/$NEW_PATH}"
  done < "$adr" > "$tmp" || { rm -f "$tmp"; rollback; echo "archive: failed to update ${adr#$ROOT/}" >&2; exit 1; }
  if ! mv "$tmp" "$adr"; then
    rm -f "$tmp"; rollback; echo "archive: failed to save ${adr#$ROOT/}" >&2; exit 1
  fi
done

if [[ -x "$SCRIPT_ROOT/validate.sh" ]] && ! "$SCRIPT_ROOT/validate.sh" "$ROOT"; then
  rollback
  echo "archive: post-update validation failed; operation rolled back" >&2
  exit 1
fi
rm -rf "$backup"
echo "archive: completed $CHANGE -> $NEW_PATH"
