#!/usr/bin/env bash
set -u

SOURCE_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROFILE=software
TARGET=
while (( $# )); do
  case "$1" in
    --profile)
      PROFILE=${2:-}
      if [[ -z "$PROFILE" ]]; then echo "usage: $0 [--profile <name>] /path/to/git-project" >&2; exit 2; fi
      shift 2;;
    --profile=*) PROFILE=${1#--profile=}; shift;;
    -h|--help) echo "usage: $0 [--profile <name>] /path/to/git-project"; echo "profiles: $(cd "$SOURCE_ROOT/template/profiles" 2>/dev/null && ls -1 | tr '\n' ' ')"; exit 0;;
    *) if [[ -n "$TARGET" ]]; then echo "init: unexpected extra argument: $1" >&2; exit 2; fi; TARGET=$1; shift;;
  esac
done
if [[ -z "$TARGET" ]]; then echo "usage: $0 [--profile <name>] /path/to/git-project" >&2; exit 2; fi

# A profile name is a single path segment: no '/', no '.', no uppercase. This is what
# keeps '..' or 'paper/..' from ever escaping template/profiles/.
if [[ ! "$PROFILE" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "init: invalid profile name '$PROFILE'; must match ^[a-z][a-z0-9-]*\$ (no path separators, no '..', lowercase only)" >&2
  exit 1
fi
PROFILE_DIR="$SOURCE_ROOT/template/profiles/$PROFILE"
available_profiles() { (cd "$SOURCE_ROOT/template/profiles" 2>/dev/null && ls -1 | tr '\n' ' '); }
if [[ ! -d "$PROFILE_DIR" ]]; then
  echo "init: unknown profile '$PROFILE'; available: $(available_profiles)" >&2
  exit 1
fi
for required in profile.md INDEX.md; do
  if [[ ! -f "$PROFILE_DIR/$required" ]]; then
    echo "init: profile '$PROFILE' is incomplete: missing template/profiles/$PROFILE/$required" >&2
    exit 1
  fi
done
if [[ ! -d "$PROFILE_DIR/knowledge" ]]; then
  echo "init: profile '$PROFILE' is incomplete: missing template/profiles/$PROFILE/knowledge/" >&2
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then echo "init: target directory does not exist: $TARGET" >&2; exit 1; fi
TARGET=$(cd "$TARGET" && pwd)
if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "init: target is not a Git repository: $TARGET" >&2; exit 1
fi

created=0; conflicts=0
frontmatter_value() {
  awk -v key="$2" '
    NR == 1 { in_front = ($0 == "---"); next }
    in_front && $0 == "---" { exit }
    in_front && index($0, key ":") == 1 { sub("^[^:]*:[[:space:]]*", ""); print; exit }
  ' "$1"
}
copy_if_missing() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then echo "CONFLICT (preserved): ${dst#$TARGET/}"; conflicts=$((conflicts+1)); return 0; fi
  mkdir -p "$(dirname "$dst")" || { echo "init: FAILED to create directory for ${dst#$TARGET/}" >&2; exit 1; }
  if ! cp -R "$src" "$dst"; then echo "init: FAILED to copy ${dst#$TARGET/}" >&2; exit 1; fi
  echo "CREATED: ${dst#$TARGET/}"; created=$((created+1))
}

# Preflight the profile overlay BEFORE writing anything. The overlay decides which profile
# the project is, so it is all-or-nothing: unlike the shared core, a differing file here
# means the requested profile cannot be honored and nothing may be written.
overlay_srcs=(); overlay_dsts=()
while IFS= read -r -d '' src; do
  overlay_srcs+=("$src"); overlay_dsts+=("$TARGET/.ai/${src#"$PROFILE_DIR/"}")
done < <(find "$PROFILE_DIR/knowledge" -type f -print0)
overlay_srcs+=("$PROFILE_DIR/INDEX.md");    overlay_dsts+=("$TARGET/.ai/INDEX.md")
overlay_srcs+=("$PROFILE_DIR/profile.md");  overlay_dsts+=("$TARGET/.ai/profile.md")

overlay_conflicts=0
if [[ -f "$TARGET/.ai/profile.md" ]]; then
  existing_profile=$(frontmatter_value "$TARGET/.ai/profile.md" name)
  if [[ -n "$existing_profile" && "$existing_profile" != "$PROFILE" ]]; then
    echo "init: PROFILE CONFLICT: .ai/profile.md declares profile '$existing_profile' but '$PROFILE' was requested" >&2
    overlay_conflicts=$((overlay_conflicts + 1))
  fi
fi
for i in "${!overlay_srcs[@]}"; do
  if [[ -e "${overlay_dsts[$i]}" ]] && ! cmp -s "${overlay_srcs[$i]}" "${overlay_dsts[$i]}"; then
    echo "init: PROFILE CONFLICT: ${overlay_dsts[$i]#$TARGET/} exists with content differing from the '$PROFILE' profile seed" >&2
    overlay_conflicts=$((overlay_conflicts + 1))
  fi
done
if (( overlay_conflicts )); then
  echo "init: profile '$PROFILE' NOT applied; no files were written ($overlay_conflicts conflict(s))" >&2
  echo "init: this project already holds a different profile; merge the overlay by hand, then re-run" >&2
  exit 1
fi

ignore_marker='# APMF derived/local memory infrastructure'
# Projects initialized before the APPM->APMF rename carry the legacy marker. Detect both so
# re-running init never appends a duplicate block; only the new marker is ever written.
legacy_ignore_marker='# APPM derived/local memory infrastructure'
ignore_block="$ignore_marker
.ai/.cache/
.ai/runtime/
.ai/index/*.db
.ai/index/*.db-*
.ai/index/*.sqlite
.ai/index/*.sqlite3
.ai/local/"
if [[ ! -f "$TARGET/.gitignore" ]]; then
  printf '%s\n' "$ignore_block" > "$TARGET/.gitignore"
  echo "CREATED: .gitignore (APMF runtime rules)"; created=$((created+1))
elif ! grep -qF "$ignore_marker" "$TARGET/.gitignore" && ! grep -qF "$legacy_ignore_marker" "$TARGET/.gitignore"; then
  printf '\n%s\n' "$ignore_block" >> "$TARGET/.gitignore"
  echo "UPDATED: .gitignore (appended APMF runtime rules)"; created=$((created+1))
else
  echo "OK: .gitignore already contains APMF runtime rules"
fi

if [[ -e "$TARGET/AGENTS.md" ]]; then
  echo "CONFLICT (preserved): AGENTS.md exists; manually merge the APMF entry protocol from template/AGENTS.md"; conflicts=$((conflicts+1))
else
  cp "$SOURCE_ROOT/template/AGENTS.md" "$TARGET/AGENTS.md"; echo "CREATED: AGENTS.md"; created=$((created+1))
fi

mkdir -p "$TARGET/.ai"
while IFS= read -r -d '' src; do
  rel=${src#"$SOURCE_ROOT/template/.ai/"}; dst="$TARGET/.ai/$rel"
  if [[ -d "$src" ]]; then mkdir -p "$dst"; continue; fi
  copy_if_missing "$src" "$dst"
done < <(find "$SOURCE_ROOT/template/.ai" -type f -print0)

# Profile overlay: knowledge seeds, INDEX router, and the declarative manifest.
# The preflight above guaranteed every destination is either absent or byte-identical,
# so this loop can only create files or skip idempotent ones — never overwrite.
overlay_applied=0
for i in "${!overlay_srcs[@]}"; do
  src=${overlay_srcs[$i]}; dst=${overlay_dsts[$i]}
  if [[ -e "$dst" ]]; then
    echo "OK (identical): ${dst#$TARGET/}"; overlay_applied=$((overlay_applied + 1)); continue
  fi
  mkdir -p "$(dirname "$dst")" || { echo "init: FAILED to create directory for ${dst#$TARGET/}" >&2; exit 1; }
  if ! cp "$src" "$dst"; then echo "init: FAILED to copy ${dst#$TARGET/}" >&2; exit 1; fi
  echo "CREATED: ${dst#$TARGET/}"; created=$((created + 1)); overlay_applied=$((overlay_applied + 1))
done
if (( overlay_applied != ${#overlay_srcs[@]} )); then
  echo "init: FAILED to process all ${#overlay_srcs[@]} profile files (handled $overlay_applied)" >&2
  exit 1
fi
echo "init: profile '$PROFILE' applied"

echo "init: created $created item(s); conflicts $conflicts"
if (( conflicts )); then echo "init: no existing files were overwritten; review conflicts before committing."; fi
