# Git aliases and functions. Multi-repo tools (gpa, gst-all, gclean) are scripts in scripts/.

unalias gco gcb gcm gup gp gwip gunwip prc 2>/dev/null

# Default branch of the current repo: origin/HEAD, else main, else master.
_git_default_branch() {
  local ref b
  if ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    print -r -- "${ref#origin/}"; return
  fi
  for b in main master; do
    if git show-ref --verify --quiet "refs/heads/$b" || git show-ref --verify --quiet "refs/remotes/origin/$b"; then
      print -r -- "$b"; return
    fi
  done
  print main
}

# desc: short status with branch
alias gs='git status -sb'
# desc: pretty one-line log graph, last 20
alias gl='git log --graph --oneline --decorate -20'
# desc: push current branch with --force-with-lease (never plain --force)
alias gpf='git push --force-with-lease'
# desc: open the current branch's PR in the browser
alias prv='gh pr view --web'
# desc: PR status for the current repo
alias prs='gh pr status'

# desc: checkout a branch: gco <branch>
gco() { git checkout "$@"; }
# desc: create and checkout a branch: gcb <branch>
gcb() { [[ -n "$1" ]] || { print -u2 "usage: gcb <branch>"; return 1; }; git checkout -b "$@"; }
# desc: checkout the repo's default branch (detected, not hardcoded)
gcm() { git checkout "$(_git_default_branch)"; }
# desc: fetch and rebase the current branch on origin's default branch
gup() { local b; b="$(_git_default_branch)"; git fetch origin && git rebase "origin/$b"; }
# desc: push; sets upstream on first push
gp() {
  if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then git push "$@"
  else git push -u origin HEAD "$@"; fi
}
# desc: quick WIP commit of everything (hooks still run)
gwip() { git add -A && git commit -m "wip: work in progress [skip ci]"; }
# desc: undo the last commit if it is a WIP commit, keeping the changes
gunwip() {
  if git log -1 --format=%s | grep -q '^wip'; then git reset HEAD~1
  else print -u2 "gunwip: last commit is not a WIP commit"; return 1; fi
}
# desc: create a PR from commits (gh pr create --fill) and open it in the browser
prc() { gh pr create --fill "$@" && gh pr view --web; }
