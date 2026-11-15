# Kubernetes helpers for prod investigation. Read-only by default:
# nothing here mutates a cluster. kctx/kns change only your local kubeconfig.

unalias kctx kns kpods klogs kev 2>/dev/null

# desc: kubectl
alias k='kubectl'

# Lazy kubectl completion: generated on first <TAB>, not at startup.
if (( $+commands[kubectl] && $+functions[compdef] )); then
  _anc_kubectl_lazy() {
    unfunction _anc_kubectl_lazy
    source <(kubectl completion zsh)
    compdef _kubectl kubectl k
    _kubectl "$@"
  }
  compdef _anc_kubectl_lazy kubectl k
fi

# desc: switch kube context (fzf picker, or kctx <name>)
kctx() {
  local c="$1"
  if [[ -z "$c" ]]; then
    (( $+commands[fzf] )) || { kubectl config get-contexts; return; }
    c="$(kubectl config get-contexts -o name | fzf --height=40% --reverse --prompt='context> ')" || return 1
  fi
  kubectl config use-context "$c"
}

# desc: switch namespace for the current context (fzf picker, or kns <ns>)
kns() {
  local n="$1"
  if [[ -z "$n" ]]; then
    (( $+commands[fzf] )) || { kubectl get ns; return; }
    n="$(kubectl get ns -o name | sed 's#^namespace/##' | fzf --height=40% --reverse --prompt='namespace> ')" || return 1
  fi
  kubectl config set-context --current --namespace="$n" >/dev/null && print "namespace: $n"
}

# desc: pods with status, restarts and age: kpods [ns]
kpods() { kubectl get pods ${1:+-n "$1"} -o wide; }

# desc: tail logs for a pod or label selector (uses stern if installed): klogs <pod|key=val> [ns]
klogs() {
  [[ -n "$1" ]] || { print -u2 "usage: klogs <pod|label=value> [ns]"; return 1; }
  if (( $+commands[stern] )); then
    if [[ "$1" == *=* ]]; then stern -l "$1" ${2:+-n "$2"} --since 15m
    else stern "$1" ${2:+-n "$2"} --since 15m; fi
  elif [[ "$1" == *=* ]]; then
    kubectl logs -f -l "$1" ${2:+-n "$2"} --tail=100 --max-log-requests=10 --prefix
  else
    kubectl logs -f "$1" ${2:+-n "$2"} --tail=100 --all-containers
  fi
}

# desc: recent warning events, newest first: kev [ns]  (all namespaces if omitted)
kev() {
  local -a scope
  if [[ -n "$1" ]]; then scope=(-n "$1"); else scope=(-A); fi
  kubectl get events "${scope[@]}" --field-selector type=Warning --sort-by=.lastTimestamp \
    | awk 'NR==1 { h=$0; next } { a[n++]=$0 } END { print h; for (i=n-1; i>=0; i--) print a[i] }' \
    | head -n 41
}
