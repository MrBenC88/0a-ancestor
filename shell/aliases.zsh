# Navigation and general aliases. Each has a `# desc:` line for `aliases`.

# desc: cd to the dev dir ($DEV_DIR)
alias gtd='cd "$DEV_DIR"'
# desc: cd to this repo ($ANCESTOR)
alias anc='cd "$ANCESTOR"'
# desc: up one dir
alias ..='cd ..'
# desc: up two dirs
alias ...='cd ../..'
# desc: re-source ~/.zshrc
alias reload='source ~/.zshrc'

if (( $+commands[eza] )); then
  # desc: list files (eza)
  alias ll='eza -la --git --group-directories-first'
else
  # desc: list files
  alias ll='ls -lah'
fi
