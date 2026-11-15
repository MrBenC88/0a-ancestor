# 0a-ancestor shell entry point. The only file ~/.zshrc sources.
# Order: env -> aliases -> git -> k8s -> agents -> functions -> local.
# Keep startup fast: no network, no slow subprocesses, lazy completions.

# Directory of this repo, resolved from this file's own path (works wherever it's cloned).
typeset -g _ANC_ROOT="${${(%):-%x}:A:h:h}"

for _anc_f in env aliases git k8s agents functions local; do
  [[ -r "$_ANC_ROOT/shell/$_anc_f.zsh" ]] && source "$_ANC_ROOT/shell/$_anc_f.zsh"
done
unset _anc_f
