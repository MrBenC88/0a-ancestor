---
name: prod-investigate
description: Use when something is wrong in production (errors, latency, outage, alert), to run a structured read-only incident flow from symptom to hypothesis and next check.
---

# prod-investigate

Structured, **read-only** incident flow. Never restart, scale, roll back, delete or apply anything without the user's explicit go-ahead for that specific command. Company specifics (clusters, dashboards, log sources, deploy tooling) come from `me/context.md`, or from a `prod-investigate-<company-tag>` skill if one exists — check `company/skills/` first and follow it alongside this one.

For a long investigation, run this as the `prod-investigator` agent (heavy lead) and hand log/k8s scans to light-tier `explorer` subagents.

## Flow

Keep a running timeline (UTC) as you go.

1. **Symptom** — what exactly is failing, for whom, since when? Error text, alert name, affected endpoint. Confirm the start time.
2. **Scope** — one user / one region / one service / everything? Blast radius drives urgency. Check status of dependencies (DB, queues, third parties) if listed in `me/context.md`.
3. **Recent changes** — deploys and config changes near the start time:
   - `gh run list --limit 10` / `gh pr list --state merged --limit 10 --search "merged:>=<date>"`
   - k8s rollouts: `kubectl rollout history deploy/<name> -n <ns>`; image tags in `kubectl get deploy <name> -o jsonpath='{..image}'`
   - Feature flags / config repos named in `me/context.md`.
4. **Logs** — `/prod-logs` (wraps `logs-errors <source> --since <window>`). Look for the top new error group that starts at the incident time.
5. **k8s state** — `/k8s-triage` (wraps `k8s-summary -n <ns>`): crash loops, OOMKilled, pending pods, failing probes, warning events.
6. **Hypothesis** — one primary, max two alternatives. Each must explain *all* the evidence, including the start time. State what would disprove it.
7. **Next check** — the single cheapest read-only command or dashboard that confirms or kills the hypothesis. Run it, update, repeat from 6.
8. **Mitigation options** — only once a hypothesis holds: list options (rollback, flag off, scale) with risk; the user decides and runs or approves each.

## Rules

- Prefer `--since`/time windows over full log dumps; never paste more than ~20 raw log lines into context.
- Prod context (`kube_prod_context` in `me/context.md`): announce before each command which context and namespace it targets.
- Write the summary to a handoff note (`/handoff`, topic `incident-<short>`) so others can pick it up.

## Output

```
Incident: <one line>          Status: investigating | mitigated | resolved
Timeline (UTC):
- HH:MM <event>
Evidence:
- <fact> (<source/command>)
Hypothesis: <primary> — disproved if <X>
Alternatives: <…>
Next check: <exact command>
Mitigation options: <only if hypothesis confirmed>
```
