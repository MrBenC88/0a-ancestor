#!/usr/bin/env bash
# Usage: ./bootstrap.sh [--check | --dry-run] [--brew] [--tag TAG]
#
# Turns a fresh clone into a working setup. Idempotent: safe to re-run.
# Never overwrites your files; conflicts are backed up to *.bak.<timestamp>.
#
#   --check     report status only; exit non-zero if anything is missing
#   --dry-run   print what would change, change nothing
#   --brew      also run `brew bundle --file=Brewfile`
#   --tag TAG   set COMPANY_TAG without prompting (short lowercase code)
set -euo pipefail
cd "$(dirname "$0")"
. scripts/lib/common.sh

CHECK=0; DRY_RUN=0; BREW=0; TAG_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --brew) BREW=1 ;;
    --tag) TAG_ARG="${2:?--tag needs a value}"; shift ;;
    -h|--help) usage_from_header "$0"; exit 0 ;;
    *) die "unknown flag: $1 (see --help)" ;;
  esac
  shift
done
[ "$CHECK" = 1 ] && [ "$DRY_RUN" = 1 ] && die "--check and --dry-run are exclusive"
export CHECK DRY_RUN ANCESTOR DEV_DIR

NEXT_STEPS=""
next() { NEXT_STEPS="$NEXT_STEPS"$'\n'"  - $*"; }
problem() { err "$*"; N_PROBLEMS=$((N_PROBLEMS + 1)); }
step() { printf '\n%s%s%s\n' "$C_BLD" "$*" "$C_RST"; }

# put_file NEW DST [MODE] -> install NEW at DST if different (honors CHECK/DRY_RUN).
put_file() {
  local new="$1" dst="$2"
  if [ -f "$dst" ] && cmp -s "$new" "$dst"; then N_SKIPPED=$((N_SKIPPED + 1)); return 0; fi
  if [ "$CHECK" = 1 ]; then
    if [ -f "$dst" ]; then problem "out of date: $dst"; else problem "missing: $dst"; fi
    return 0
  fi
  if [ "$DRY_RUN" = 1 ]; then dim "would write $dst"; return 0; fi
  mkdir -p "$(dirname "$dst")"; cp "$new" "$dst"
  [ -n "${3:-}" ] && chmod "$3" "$dst"
  N_LINKED=$((N_LINKED + 1)); ok "wrote $dst"
}

# copy_if_missing SRC DST
copy_if_missing() {
  if [ -e "$2" ]; then N_SKIPPED=$((N_SKIPPED + 1)); return 0; fi
  if [ "$CHECK" = 1 ]; then problem "missing: $2"; return 0; fi
  N_LINKED=$((N_LINKED + 1))
  if [ "$DRY_RUN" = 1 ]; then dim "would create $2"; else cp -R "$1" "$2"; ok "created $2"; fi
}

# sub_script NAME ARGS -> run a sibling script with our mode flags.
sub_script() {
  local s="$1"; shift
  local flags=""
  [ "$CHECK" = 1 ] && flags="--check"
  [ "$DRY_RUN" = 1 ] && flags="--dry-run"
  # shellcheck disable=SC2086  # flags is empty or one word
  "scripts/$s" $flags "$@" || N_PROBLEMS=$((N_PROBLEMS + 1))
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mode="apply"; [ "$CHECK" = 1 ] && mode="check"; [ "$DRY_RUN" = 1 ] && mode="dry-run"
info "${C_BLD}0a-ancestor bootstrap${C_RST} ($mode)"
dim "ANCESTOR=$ANCESTOR"
dim "DEV_DIR=$DEV_DIR"

# --- 0. optional brew ----------------------------------------------------------
if [ "$BREW" = 1 ]; then
  step "brew bundle"
  if ! command -v brew >/dev/null 2>&1; then problem "brew not installed (https://brew.sh)"
  elif [ "$CHECK" = 1 ]; then brew bundle check --file=Brewfile || problem "Brewfile not satisfied"
  else run brew bundle --file=Brewfile; fi
fi

# --- 2. root rule links --------------------------------------------------------
step "Agent rules in $DEV_DIR"
ensure_link "$ANCESTOR/AGENTS.md" "$DEV_DIR/AGENTS.md"
ensure_link "$ANCESTOR/CLAUDE.md" "$DEV_DIR/CLAUDE.md"

# --- 3. skills -----------------------------------------------------------------
step "Skills"
sub_script link-skills

# --- 4. agents -----------------------------------------------------------------
step "Agents"
sub_script gen-agents

# --- 5. shell ------------------------------------------------------------------
step "Shell"
init_path="$ANCESTOR/shell/init.zsh"
case "$init_path" in "$HOME"/*) init_ref="\$HOME/${init_path#"$HOME"/}" ;; *) init_ref="$init_path" ;; esac
zshrc_line="[ -f \"$init_ref\" ] && source \"$init_ref\""
zshrc="$HOME/.zshrc"
if [ -f "$zshrc" ] && grep -qF "$init_ref" "$zshrc"; then
  N_SKIPPED=$((N_SKIPPED + 1))
elif [ "$CHECK" = 1 ]; then
  problem "$HOME/.zshrc does not source $init_ref"
elif [ "$DRY_RUN" = 1 ]; then
  dim "would append to ~/.zshrc: $zshrc_line"
else
  printf '\n# 0a-ancestor\n%s\n' "$zshrc_line" >> "$zshrc"
  N_LINKED=$((N_LINKED + 1)); ok "added source line to ~/.zshrc"
  next "open a new shell (or: exec zsh), then run: gtd && aliases"
fi
copy_if_missing shell/local.zsh.template shell/local.zsh

# --- 6. company tag + commit guards --------------------------------------------
step "Company tag"
tag="$(local_var COMPANY_TAG)"
if [ -z "$tag" ] && [ "$CHECK" = 0 ]; then
  tag="${TAG_ARG:-${COMPANY_TAG:-}}"
  if [ -z "$tag" ] && [ -t 0 ] && [ "$DRY_RUN" = 0 ]; then
    printf 'Short lowercase company tag (e.g. 2-8 letters, kept local only): ' >&2
    read -r tag || tag=""
  fi
  if [ -n "$tag" ]; then
    printf '%s' "$tag" | grep -qE '^[a-z0-9]{2,12}$' || die "tag must be 2-12 lowercase letters/digits"
    if [ "$DRY_RUN" = 1 ]; then dim "would set COMPANY_TAG=$tag in shell/local.zsh"
    else
      if grep -qE '^[[:space:]]*(export[[:space:]]+)?COMPANY_TAG=' shell/local.zsh; then
        sed -E "s/^[[:space:]]*(export[[:space:]]+)?COMPANY_TAG=.*/export COMPANY_TAG=\"$tag\"/" shell/local.zsh > "$TMP/local.zsh"
        cat "$TMP/local.zsh" > shell/local.zsh
      else
        printf 'export COMPANY_TAG="%s"\n' "$tag" >> shell/local.zsh
      fi
      ok "set COMPANY_TAG in shell/local.zsh"
    fi
  fi
fi
if [ -z "$tag" ]; then
  if [ "$CHECK" = 1 ]; then problem "COMPANY_TAG not set in shell/local.zsh"
  else warn "no company tag set; re-run with --tag <code> to enable commit guards"; next "set a company tag: ./bootstrap.sh --tag <code>"; fi
else
  ok "COMPANY_TAG is set (value kept local)"
  exclude="$(git rev-parse --git-path info/exclude)"
  pat="*-$tag*"
  if [ -f "$exclude" ] && grep -qxF "$pat" "$exclude"; then N_SKIPPED=$((N_SKIPPED + 1))
  elif [ "$CHECK" = 1 ]; then problem "tag pattern missing from .git/info/exclude"
  elif [ "$DRY_RUN" = 1 ]; then dim "would add tag pattern to .git/info/exclude"
  else mkdir -p "$(dirname "$exclude")"; printf '%s\n' "$pat" >> "$exclude"; ok "added tag pattern to .git/info/exclude"; fi
fi

hook="$(git rev-parse --git-path hooks/pre-commit)"
cat > "$TMP/pre-commit" <<EOF
#!/bin/sh
# 0a-ancestor pre-commit wrapper (installed by bootstrap.sh)
exec "$ANCESTOR/scripts/lib/pre-commit-hook" "\$@"
EOF
if [ -e "$hook" ] && ! grep -q '0a-ancestor pre-commit wrapper' "$hook"; then
  if [ "$CHECK" = 1 ]; then problem "foreign pre-commit hook at $hook"; else backup "$hook"; fi
fi
put_file "$TMP/pre-commit" "$hook" 755

# --- 7. editor -----------------------------------------------------------------
step "Editor"
copy_if_missing editor/.vscode "$DEV_DIR/.vscode"
ws="$DEV_DIR/dev.code-workspace"
{
  printf '// generated by 0a-ancestor/bootstrap.sh; re-run it to refresh\n{\n  "folders": [\n'
  first=1
  while IFS= read -r r; do
    [ "$first" = 1 ] || printf ',\n'
    printf '    { "path": "%s" }' "$(basename "$r")"
    first=0
  done < <(list_repos all)
  printf '\n  ],\n  "settings": {}\n}\n'
} > "$TMP/ws"
if [ -f "$ws" ] && ! grep -q 'generated by 0a-ancestor' "$ws"; then
  warn "$ws was edited by hand; leaving it alone"; N_SKIPPED=$((N_SKIPPED + 1))
else
  put_file "$TMP/ws" "$ws"
fi

# --- 8. personal files ---------------------------------------------------------
step "Personal files (me/, handoff/)"
for t in me/*.template.md; do
  copy_if_missing "$t" "${t%.template.md}.md"
done
if [ -n "$tag" ] && [ -f me/context.md ] && grep -q '^company_tag: <company-tag>$' me/context.md; then
  if [ "$CHECK" = 1 ]; then problem "company_tag not filled in me/context.md"
  elif [ "$DRY_RUN" = 1 ]; then dim "would set company_tag in me/context.md"
  else
    sed "s/^company_tag: <company-tag>\$/company_tag: $tag/" me/context.md > "$TMP/ctx" && cat "$TMP/ctx" > me/context.md
    ok "set company_tag in me/context.md"
  fi
fi
for d in handoff company/skills company/agents; do
  if [ -d "$d" ]; then N_SKIPPED=$((N_SKIPPED + 1))
  elif [ "$CHECK" = 1 ]; then problem "missing dir: $d"
  else run mkdir -p "$d"; fi
done
grep -q '^jira_site: <' me/context.md 2>/dev/null && next "fill in me/context.md (company values) and me/onboarding.md"

# --- 9. repo index -------------------------------------------------------------
step "Repo index"
if [ -x scripts/index-repos ]; then sub_script index-repos; else warn "scripts/index-repos missing"; fi

# --- 10. summary ---------------------------------------------------------------
printf '\n%sSummary%s\n' "$C_BLD" "$C_RST"
if [ "$CHECK" = 1 ]; then
  if [ "$N_PROBLEMS" = 0 ]; then ok "all green"; exit 0; fi
  err "$N_PROBLEMS problem(s); run ./bootstrap.sh to fix"; exit 1
fi
info "  linked/written: $N_LINKED · unchanged: $N_SKIPPED · backed up: $N_BACKED · problems: $N_PROBLEMS"
dim "  (sub-steps print their own counts above)"
[ -n "$NEXT_STEPS" ] && info "Next:$NEXT_STEPS"
[ "$N_PROBLEMS" = 0 ]
