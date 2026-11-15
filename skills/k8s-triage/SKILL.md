---
name: k8s-triage
description: Use when checking Kubernetes health for a namespace or cluster, to run k8s-summary, interpret it and suggest the next read-only command.
---

# k8s-triage

Read-only. Wraps `k8s-summary` (≤ 40 lines of output) so raw `kubectl get` tables never flood context.

## Steps

1. Pick context/namespace from the user or `me/context.md` (`kube_contexts`, `kube_default_namespace`). If it's the prod context, say so before running anything.
2. Run `k8s-summary [-n <ns>] [--context <ctx>]`.
3. Interpret each flagged item with the table below.
4. Suggest **one** next read-only command per problem (max 3), most likely root cause first.

| Signal | Usually means | Next read-only command |
| --- | --- | --- |
| `CrashLoopBackOff` | app exits on start: config, missing secret, bad migration | `kubectl logs <pod> -n <ns> --previous --tail=50` |
| `last: OOMKilled` + restarts | memory limit too low or a leak | `kubectl top pod <pod> -n <ns>`; compare to `resources.limits` |
| `ImagePullBackOff` / `ErrImagePull` | wrong tag, registry auth | `kubectl describe pod <pod> -n <ns> \| tail -20` |
| `Pending` | no capacity, unbound PVC, node selector/taints | `kubectl describe pod <pod> -n <ns> \| sed -n '/Events/,$p'` |
| Running but not ready | readiness probe failing, dependency down | `kubectl describe pod <pod>` (probe section) + app logs |
| `CreateContainerConfigError` | missing ConfigMap/Secret key | `kubectl get events -n <ns> --field-selector involvedObject.name=<pod>` |
| Many restarts, now healthy | flapping; check timing vs deploys | `kubectl rollout history deploy/<name> -n <ns>` |
| `FailedScheduling`, `BackOff`, `Unhealthy` events | see above by reason | `kev <ns>` |

5. For logs, hand off to `/prod-logs` with `k8s:<pod>` or `k8s:app=<label>`.

## Rules

- No `delete`, `rollout restart`, `scale`, `apply`, `edit`, `cordon`, `drain` unless the user explicitly asks for that exact command; then show it and confirm first.

## Output

```
<ctx>/<ns>: <n> pods, <n> unhealthy, <n> restarting
1. <pod> — <signal> → likely <cause>. Next: `<command>`
2. ...
Warnings worth noting: <one line or none>
```
