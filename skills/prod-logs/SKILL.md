---
name: prod-logs
description: Use when you need to know what errors a service is logging, to run logs-errors, group and dedupe the errors and link the top ones to code paths.
---

# prod-logs

Read-only. Wraps `logs-errors`, which groups error lines by normalized message and counts them, so raw logs stay out of context.

## Steps

1. **Pick the source.** Named sources live in `me/context.md` (`log_sources:`). Map them to a `logs-errors` source form:
   - `k8s:<pod>` or `k8s:<label>=<value>` (e.g. `k8s:app=api`)
   - a file or dir of `*.log`
   - `-` for stdin, e.g. `<vendor-cli> logs … | logs-errors -`
2. **Run** with a tight window: `logs-errors <source> --since 30m --top 10`. Widen only if empty.
3. **Dedupe across sources**: the same normalized message from several pods is one issue; sum the counts.
4. **Separate new from chronic**: if the user has a baseline window, run again for it (e.g. the same hour yesterday via a file source) and mark groups that are new or spiking.
5. **Link to code** for the top 3 groups: take a distinctive literal fragment of the message (not the `<n>`/`<id>` placeholders) and `rg -n --fixed-strings "<fragment>" <repo>`; if there's a stack trace, use the top in-app frame. Report `path:line`.
6. For one group, if detail is needed: `logs-errors <source> --full --pattern '<fragment>' | head -20`.

## Rules

- Never paste more than ~20 raw log lines into context. No customer PII in notes or tickets; redact emails, tokens and IDs.

## Output

```
Source: <source>, window <since>: <total> error lines, <groups> groups
1. ×<count> <normalized message>  [new|chronic]  → <path:line or "no code match">
2. ...
Likely related: <groups that share a cause, or none>
```
