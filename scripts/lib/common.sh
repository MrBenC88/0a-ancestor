#!/usr/bin/env bash
# Shared helpers for 0a-ancestor scripts. Source it; don't run it.
# Bash 3.2-compatible (macOS default): no assoc arrays, mapfile, wait -n.
# shellcheck disable=SC2034  # color vars are used by the sourcing scripts

# --- paths -------------------------------------------------------------------
_common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ANCESTOR="${ANCESTOR:-$(cd "$_common_dir/../.." && pwd -P)}"
DEV_DIR="${DEV_DIR:-$(cd "$ANCESTOR/.." && pwd -P)}"
ANCESTOR_NAME="$(basename "$ANCESTOR")"
LOCAL_ZSH="$ANCESTOR/shell/local.zsh"
CONTEXT_MD="$ANCESTOR/me/context.md"

# --- colors ------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'; C_DIM=$'\033[2m'; C_BLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_RED=''; C_GRN=''; C_YEL=''; C_BLU=''; C_DIM=''; C_BLD=''; C_RST=''
fi

info() { printf '%s\n' "$*"; }
ok()   { printf '%s✓%s %s\n' "$C_GRN" "$C_RST" "$*"; }
warn() { printf '%s⚠%s %s\n' "$C_YEL" "$C_RST" "$*" >&2; }
err()  { printf '%s✗%s %s\n' "$C_RED" "$C_RST" "$*" >&2; }
die()  { err "$*"; exit 1; }
dim()  { printf '%s%s%s\n' "$C_DIM" "$*" "$C_RST"; }

# Print the header block of the calling script (lines starting with '# ' after
# the shebang, up to the first blank/non-comment line) as --help text.
usage_from_header() {
  awk 'NR==1{next} /^#( |$)/{sub(/^# ?/,""); if ($0 !~ /^desc:/ && $0 !~ /^shellcheck/) print; next} {exit}' "$1"
}

# --- safety ------------------------------------------------------------------
# confirm "Question?"  -> returns 0 on y/yes. Honors ASSUME_YES=1.
confirm() {
  [ "${ASSUME_YES:-0}" = 1 ] && return 0
  if [ ! -t 0 ]; then
    warn "no terminal for confirmation; re-run with --yes to proceed"
    return 1
  fi
  local reply
  printf '%s [y/N] ' "$1" >&2
  read -r reply || return 1
  case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# run CMD...  -> executes, or prints it when DRY_RUN=1.
run() {
  if [ "${DRY_RUN:-0}" = 1 ]; then
    printf '%swould run:%s %s\n' "$C_DIM" "$C_RST" "$*"
  else
    "$@"
  fi
}

need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found${2:+ — $2}"; }

# --- local config ------------------------------------------------------------
# local_var NAME -> value of `NAME=...` / `export NAME=...` in shell/local.zsh.
# Parsed, not sourced (local.zsh is zsh and may run commands).
local_var() {
  [ -f "$LOCAL_ZSH" ] || return 0
  sed -n -E "s/^[[:space:]]*(export[[:space:]]+)?$1=[\"']?([^\"'#]*)[\"']?.*$/\\2/p" "$LOCAL_ZSH" \
    | tail -n 1 | sed -E 's/[[:space:]]+$//'
}

# context_var key -> value of `key: value` in me/context.md (empty if placeholder).
context_var() {
  [ -f "$CONTEXT_MD" ] || return 0
  sed -n -E "s/^$1:[[:space:]]*(.*)$/\\1/p" "$CONTEXT_MD" | head -n 1 | grep -v '^<' || true
}

# company_tag -> COMPANY_TAG from env, local.zsh, then me/context.md.
company_tag() {
  local t="${COMPANY_TAG:-}"
  [ -n "$t" ] || t="$(local_var COMPANY_TAG)"
  [ -n "$t" ] || t="$(context_var company_tag)"
  printf '%s' "$t"
}

# --- repos -------------------------------------------------------------------
# list_repos [all] -> absolute paths of git repos directly under DEV_DIR.
# Skips 0a-ancestor unless "all" is given. Honors ONLY_GLOB.
list_repos() {
  local d name
  for d in "$DEV_DIR"/*/; do
    d="${d%/}"
    [ -e "$d/.git" ] || continue
    name="$(basename "$d")"
    if [ "$name" = "$ANCESTOR_NAME" ] && [ "${1:-}" != all ]; then continue; fi
    if [ -n "${ONLY_GLOB:-}" ]; then
      # shellcheck disable=SC2254  # glob match is the point
      case "$name" in $ONLY_GLOB) ;; *) continue ;; esac
    fi
    printf '%s\n' "$d"
  done
}

# default_branch [repo] -> origin/HEAD target, else main, else master.
default_branch() {
  local repo="${1:-.}" ref b
  if ref="$(git -C "$repo" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    printf '%s' "${ref#origin/}"; return 0
  fi
  for b in main master; do
    if git -C "$repo" show-ref --verify --quiet "refs/heads/$b" ||
       git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$b"; then
      printf '%s' "$b"; return 0
    fi
  done
  printf 'main'
}

# is_dirty [repo] -> 0 if tracked files have staged or unstaged changes.
is_dirty() {
  [ -n "$(git -C "${1:-.}" status --porcelain --untracked-files=no 2>/dev/null)" ]
}

# detect_stack repo -> short comma list (node, go, python, ...).
detect_stack() {
  local r="$1" s=""
  [ -f "$r/package.json" ] && s="$s,node"
  [ -f "$r/tsconfig.json" ] && s="$s,ts"
  [ -f "$r/next.config.js" ] || [ -f "$r/next.config.mjs" ] || [ -f "$r/next.config.ts" ] && s="$s,next"
  [ -f "$r/go.mod" ] && s="$s,go"
  [ -f "$r/Cargo.toml" ] && s="$s,rust"
  { [ -f "$r/pyproject.toml" ] || [ -f "$r/requirements.txt" ]; } && s="$s,python"
  { [ -f "$r/pom.xml" ] || [ -f "$r/build.gradle" ] || [ -f "$r/build.gradle.kts" ]; } && s="$s,jvm"
  [ -f "$r/Gemfile" ] && s="$s,ruby"
  { [ -f "$r/Dockerfile" ] || [ -d "$r/helm" ] || [ -d "$r/k8s" ] || [ -d "$r/charts" ]; } && s="$s,docker/k8s"
  [ -f "$r/Makefile" ] && s="$s,make"
  s="${s#,}"
  printf '%s' "${s:--}"
}

# --- links -------------------------------------------------------------------
# Counters for summaries; scripts print them at the end.
N_LINKED=0; N_SKIPPED=0; N_BACKED=0; N_PROBLEMS=0
TS="$(date +%Y%m%d%H%M%S)"

# backup PATH -> move aside to PATH.bak.<timestamp>.
backup() {
  run mv "$1" "$1.bak.$TS"
  N_BACKED=$((N_BACKED + 1))
  warn "backed up $1 -> $1.bak.$TS"
}

# ensure_link SRC DST -> symlink DST to SRC. Idempotent; backs up conflicts.
# With CHECK=1 only reports.
ensure_link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    N_SKIPPED=$((N_SKIPPED + 1)); return 0
  fi
  if [ "${CHECK:-0}" = 1 ]; then
    if [ -e "$dst" ] || [ -L "$dst" ]; then err "conflict: $dst (not linked to $src)"
    else err "missing link: $dst"; fi
    N_PROBLEMS=$((N_PROBLEMS + 1)); return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then backup "$dst"; fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  N_LINKED=$((N_LINKED + 1))
  ok "linked $dst"
}

# prune_dead_links DIR -> remove dangling symlinks in DIR that point into ANCESTOR.
prune_dead_links() {
  local l t
  [ -d "$1" ] || return 0
  for l in "$1"/*; do
    [ -L "$l" ] || continue
    [ -e "$l" ] && continue
    t="$(readlink "$l")"
    case "$t" in "$ANCESTOR"/*)
      if [ "${CHECK:-0}" = 1 ]; then err "dangling link: $l"; N_PROBLEMS=$((N_PROBLEMS + 1))
      else run rm "$l"; ok "removed dangling $l"; fi ;;
    esac
  done
}
