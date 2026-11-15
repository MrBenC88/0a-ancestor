# Agent CLI shortcuts. Note: `cc` shadows the C compiler in interactive shells only
# (scripts and make are unaffected); use `command cc` if you need the compiler.

unalias handoff wl 2>/dev/null

# desc: claude in the current dir
alias cc='claude'
# desc: resume a claude session
alias ccr='claude --resume'
# desc: codex in the current dir
alias cx='codex'

# Project name for handoffs: the git repo's dir name, else the current dir's.
_anc_project() {
  local top
  top="$(git rev-parse --show-toplevel 2>/dev/null)" || top="$PWD"
  print -r -- "${top:t}"
}

# desc: print the active handoff note (LATEST.md) for the current repo
handoff() {
  local p="${1:-$(_anc_project)}" f
  f="$ANCESTOR/handoff/$p/LATEST.md"
  [[ -e "$f" ]] || { print -u2 "handoff: no $f (write one with /handoff)"; return 1; }
  if (( $+commands[bat] )); then bat --style=plain --language=md "$f"; else cat "$f"; fi
}

# desc: append a timestamped line to me/worklog.md: wl "<text>"
wl() {
  [[ -n "$*" ]] || { print -u2 'usage: wl "<text>"'; return 1; }
  local log="$ANCESTOR/me/worklog.md" today
  today="$(date +%Y-%m-%d)"
  [[ -f "$log" ]] || cp "$ANCESTOR/me/worklog.template.md" "$log"
  grep -q "^## $today\$" "$log" || print -r -- $'\n'"## $today"$'\n' >> "$log"
  print -r -- "- $(date +%H:%M) $*" >> "$log"
  print "logged: $*"
}
