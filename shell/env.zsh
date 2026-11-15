# Environment. Overridable in local.zsh (sourced last).

export ANCESTOR="${ANCESTOR:-${_ANC_ROOT:-$HOME/dev/0a-ancestor}}"
export DEV_DIR="${DEV_DIR:-${ANCESTOR:h}}"   # parent of this repo; ~/dev by convention

typeset -U path   # no duplicate PATH entries on reload
path=("$ANCESTOR/scripts" $path)

export EDITOR="${EDITOR:-code --wait}"
export VISUAL="${VISUAL:-$EDITOR}"
