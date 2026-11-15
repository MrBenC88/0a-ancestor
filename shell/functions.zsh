# General functions. Each has a `# desc:` line for `aliases`.

# Frameworks (e.g. oh-my-zsh) may define aliases with these names; a function can't replace an alias.
unalias d mkcd aliases 2>/dev/null

# desc: fuzzy jump to a repo in $DEV_DIR (exact match first): d <name>
d() {
  local q="$1" dir
  if [[ -n "$q" && -d "$DEV_DIR/$q" ]]; then cd "$DEV_DIR/$q"; return; fi
  local -a repos
  repos=("$DEV_DIR"/*(/N:t))
  if (( $+commands[fzf] )); then
    dir="$(print -rl -- $repos | fzf --height=40% --reverse --select-1 --exit-0 --query="$q")" || return 1
  else
    dir="${${(M)repos:#${q}*}[1]:-${${(M)repos:#*${q}*}[1]}}"
  fi
  [[ -n "$dir" ]] || { print -u2 "d: no repo matches '$q'"; return 1; }
  cd "$DEV_DIR/$dir"
}

# desc: make a dir (with parents) and cd into it: mkcd <dir>
mkcd() { [[ -n "$1" ]] || { print -u2 "usage: mkcd <dir>"; return 1; }; mkdir -p -- "$1" && cd -- "$1"; }

# desc: list aliases, functions and scripts added by 0a-ancestor, with descriptions
aliases() {
  local f
  {
    for f in "$ANCESTOR"/shell/*.zsh(N); do
      awk -v src="${f:t:r}" '
        /^[ \t]*# desc:/ { d=$0; sub(/^[ \t]*# desc:[ \t]*/, "", d); next }
        d != "" {
          n=""
          if (match($0, /^[ \t]*alias [^=]+=/)) { n=substr($0, RSTART, RLENGTH-1); sub(/^[ \t]*alias /, "", n) }
          else if (match($0, /^[ \t]*(function[ \t]+)?[A-Za-z0-9_.-]+[ \t]*\(\)/)) { n=substr($0, RSTART, RLENGTH); sub(/^[ \t]*(function[ \t]+)?/, "", n); sub(/[ \t]*\(\)$/, "", n) }
          if (n != "") printf "%-14s %-10s %s\n", n, src, d
          d=""
        }' "$f"
    done
    for f in "$ANCESTOR"/scripts/*(N.x); do
      awk -v n="${f:t}" '/^# desc:/ { d=$0; sub(/^# desc:[ \t]*/, "", d); printf "%-14s %-10s %s\n", n, "script", d; exit }' "$f"
    done
  } | sort -k2,2 -k1,1
}
