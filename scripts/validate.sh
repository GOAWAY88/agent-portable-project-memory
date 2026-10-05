#!/usr/bin/env bash
# APMF V0.2 canonical-memory integrity checks. No YAML/Markdown parser required.
set -u

ROOT=${1:-.}
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "validate: target does not exist: ${1:-.}" >&2; exit 2; }
fail=0

error() { echo "ERROR: $*" >&2; fail=1; }
need() { [[ -e "$ROOT/$1" ]] || error "missing $1"; }
frontmatter_value() {
  awk -v key="$2" '
    NR == 1 { in_front = ($0 == "---"); next }
    in_front && $0 == "---" { exit }
    in_front && index($0, key ":") == 1 { sub("^[^:]*:[[:space:]]*", ""); print; exit }
  ' "$1"
}
require_frontmatter() {
  local file=$1 key=$2 value
  value=$(frontmatter_value "$file" "$key")
  [[ -n "$value" ]] || error "missing front-matter '$key' in ${file#$ROOT/}"
  printf '%s' "$value"
}
valid_date() { [[ "$1" == "YYYY-MM-DD" || "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; }
verify_commit() {
  local value=$1 file=$2
  case "$value" in unknown|null|none|"[commit]"|"") return ;; esac
  if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 && ! git -C "$ROOT" cat-file -e "${value}^{commit}" 2>/dev/null; then
    error "unresolvable verified_at_commit '$value' in ${file#$ROOT/}"
  fi
}
valid_knowledge_status() { case "$1" in current|draft|deprecated|superseded) return 0;; *) return 1;; esac; }
valid_adr_status() { case "$1" in proposed|accepted|rejected|deprecated|superseded) return 0;; *) return 1;; esac; }

for p in AGENTS.md .ai/NOW.md .ai/INDEX.md .ai/knowledge .ai/decisions .ai/changes .ai/archive; do need "$p"; done

# Required knowledge set: declared by .ai/profile.md when present (V0.3 profiles);
# otherwise fall back to the frozen software defaults for backward compatibility.
profile_file="$ROOT/.ai/profile.md"
if [[ -f "$profile_file" ]]; then
  profile_name=$(frontmatter_value "$profile_file" name)
  [[ "$profile_name" =~ ^[a-z][a-z0-9-]*$ ]] || error "invalid profile name '$profile_name' in .ai/profile.md"
  required_knowledge=$(frontmatter_value "$profile_file" required_knowledge)
  if [[ -n "$required_knowledge" ]]; then
    # Split without glob expansion, then require a plain filename: no '/', no traversal,
    # no absolute path, and a mandatory .md suffix. Anything else could reference a file
    # outside .ai/knowledge/ and silently satisfy the required-knowledge contract.
    read -r -a required_entries <<< "$required_knowledge"
    for k in "${required_entries[@]}"; do
      if [[ ! "$k" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*\.md$ ]]; then
        error "required_knowledge entry '$k' in .ai/profile.md is not a plain .md filename (no paths, no '..', no separators)"
        continue
      fi
      need ".ai/knowledge/$k"
    done
  else
    error "missing front-matter 'required_knowledge' in .ai/profile.md"
  fi
else
  for p in PROJECT.md ARCHITECTURE.md COMMANDS.md; do need ".ai/knowledge/$p"; done
fi

NOW="$ROOT/.ai/NOW.md"
for label in Project Milestone "Active change" "Current task" Blockers "Next action" "Last verified state"; do
  grep -q "^${label}:" "$NOW" || error "missing NOW field '$label'"
done
now_updated=$(require_frontmatter "$NOW" updated)
valid_date "$now_updated" || error "invalid NOW updated date '$now_updated'"
require_frontmatter "$NOW" branch >/dev/null
now_commit=$(require_frontmatter "$NOW" verified_at_commit)
verify_commit "$now_commit" "$NOW"

active=$(sed -n 's/^Active change:[[:space:]]*\*\*\([^*]*\)\*\*.*$/\1/p' "$NOW" | head -n 1)
if [[ -z "$active" ]]; then active=$(frontmatter_value "$NOW" active_change); fi
[[ -n "$active" ]] || error "NOW does not name an active change"
if [[ "$active" != "none" && "$active" != "[active-change]" && ! "$active" =~ ^[a-z0-9][a-z0-9.-]*$ ]]; then
  error "invalid active change name '$active'"
fi

# INDEX is a router. Validate local file/directory references written as inline code or Markdown links.
index_paths=0
while IFS= read -r token; do
  path=${token#\`}; path=${path%\`}
  [[ "$path" == *"<"* || "$path" == *">"* || "$path" == *" "* ]] && continue
  case "$path" in .ai/*|./*|AGENTS.md|*/*|*/ ) ;; *) continue;; esac
  path=${path#./}
  [[ -e "$ROOT/$path" ]] || error "INDEX path does not exist: $path"
  index_paths=$((index_paths + 1))
done < <(grep -oE '`[^`]+`' "$ROOT/.ai/INDEX.md" || true)
while IFS= read -r token; do
  path=${token#](}; path=${path%)}; path=${path%%#*}
  case "$path" in ""|http://*|https://*|mailto:*|/*|*" "*) continue;; esac
  [[ -e "$ROOT/$path" ]] || error "INDEX link does not exist: $path"
  index_paths=$((index_paths + 1))
done < <(grep -oE '\]\([^)]+\)' "$ROOT/.ai/INDEX.md" || true)
(( index_paths > 0 )) || error "INDEX contains no local memory paths"

shopt -s nullglob
for knowledge in "$ROOT"/.ai/knowledge/*.md; do
  base=$(basename "$knowledge")
  [[ "$base" == "README.md" ]] && continue
  require_frontmatter "$knowledge" id >/dev/null
  status=$(require_frontmatter "$knowledge" status)
  valid_knowledge_status "$status" || error "invalid knowledge status '$status' in .ai/knowledge/$base"
  updated=$(require_frontmatter "$knowledge" updated)
  valid_date "$updated" || error "invalid updated date '$updated' in .ai/knowledge/$base"
  commit=$(require_frontmatter "$knowledge" verified_at_commit)
  verify_commit "$commit" "$knowledge"
done

for adr in "$ROOT"/.ai/decisions/*.md; do
  base=$(basename "$adr")
  [[ "$base" == "README.md" || "$base" == "ADR-TEMPLATE.md" ]] && continue
  [[ "$base" =~ ^ADR-[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$ ]] || { error "invalid ADR filename: $base"; continue; }
  id=$(require_frontmatter "$adr" id)
  [[ "$id" == "${base%.md}" ]] || error "ADR id '$id' does not match filename $base"
  grep -q "^# ${id}:" "$adr" || error "ADR heading does not match id in $base"
  status=$(require_frontmatter "$adr" status)
  valid_adr_status "$status" || error "invalid ADR status '$status' in $base"
  for field in created updated verified_at_commit supersedes superseded_by evidence; do require_frontmatter "$adr" "$field" >/dev/null; done
  valid_date "$(frontmatter_value "$adr" created)" || error "invalid created date in $base"
  valid_date "$(frontmatter_value "$adr" updated)" || error "invalid updated date in $base"
  commit=$(frontmatter_value "$adr" verified_at_commit); verify_commit "$commit" "$adr"
  evidence=$(frontmatter_value "$adr" evidence)
  if [[ "$status" == "accepted" && "$evidence" == "[]" ]]; then error "accepted ADR lacks evidence in $base"; fi
  case "$evidence" in
    .ai/*|./.ai/*|AGENTS.md|README.md|ABOUT.md|CHANGELOG.md|docs/*|spec/*|scripts/*|tests/*|template/*)
      evidence=${evidence#./}
      [[ -e "$ROOT/$evidence" ]] || error "ADR evidence path does not exist: $evidence in $base";;
  esac
done

check_change() {
  local dir=$1 name tasks token statuses all_done=1 seen=0
  name=$(basename "$dir")
  for artifact in proposal.md design.md tasks.md evidence.md; do need ".ai/changes/$name/$artifact"; done
  [[ -f "$dir/proposal.md" ]] && for heading in Problem Motivation Scope "Non-goals" "Success criteria"; do grep -qi "^## $heading" "$dir/proposal.md" || error "proposal.md missing '$heading' in $name"; done
  [[ -f "$dir/design.md" ]] && for heading in Approach "Tradeoffs" Risks "Rejected alternatives"; do grep -qi "^## $heading" "$dir/design.md" || error "design.md missing '$heading' in $name"; done
  [[ -f "$dir/evidence.md" ]] && grep -qE '^[[:space:]]*\||^[[:space:]]*[^#[:space:]]' "$dir/evidence.md" || error "evidence.md has no evidence content in $name"
  [[ -f "$dir/evidence.md" ]] && grep -qiE 'branch|commit|sha' "$dir/evidence.md" || error "evidence.md lacks branch/commit provenance in $name"
  tasks="$dir/tasks.md"
  if [[ -f "$tasks" ]]; then
    statuses=$(grep -oE '`[A-Z_]+`' "$tasks" || true)
    [[ -n "$statuses" ]] || error "tasks.md has no status tokens in $name"
    if [[ -n "$statuses" ]]; then
      while IFS= read -r token; do
        token=${token#\`}; token=${token%\`}; seen=1
        case "$token" in TODO|IN_PROGRESS|BLOCKED) all_done=0;; DONE) ;; *) error "invalid task status '$token' in $name"; all_done=0;; esac
      done <<< "$statuses"
    fi
    if (( seen && all_done )); then error "completed change remains active: .ai/changes/$name (archive it)"; fi
  fi
}

if [[ "$active" != "none" && "$active" != "[active-change]" ]]; then
  [[ -d "$ROOT/.ai/changes/$active" ]] || error "NOW active change does not exist: .ai/changes/$active"
fi
for change in "$ROOT"/.ai/changes/*; do
  [[ -d "$change" && "$(basename "$change")" != "_template" ]] || continue
  check_change "$change"
done

if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r -d '' tracked; do
    case "$tracked" in .ai/.cache/*|.ai/runtime/*|.ai/index/*.db|.ai/index/*.db-*|.ai/index/*.sqlite|.ai/index/*.sqlite3|.ai/local/*)
      error "derived runtime file is tracked: $tracked";; esac
  done < <(git -C "$ROOT" ls-files -z -- .ai)
fi

if (( fail )); then echo "validate: FAILED" >&2; exit 1; fi
echo "validate: OK ($ROOT)"
