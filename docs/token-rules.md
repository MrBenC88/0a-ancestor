# Token efficiency rules

Token efficiency is a hard constraint. Always-loaded context stays small; everything else loads on demand. `AGENTS.md` carries the summary; this is the detail.

## Budgets

| Thing | Budget |
| --- | --- |
| Root `AGENTS.md`, each repo `AGENTS.md` | ≤ 100 lines |
| `CLAUDE.md` shim | `@AGENTS.md` + ≤ 10 lines |
| Skill description (frontmatter) | one sentence, says **when** to use it |
| Skill body | ≤ ~150 lines; long reference in `references/` |
| Script output | ≤ 50 lines by default; `--full` for raw |
| Subagent reply | ≤ 15 lines; detail goes to `handoff/` |
| Handoff note | ≤ 60 lines |

Anything over budget gets split: keep the rule, move the detail to `docs/<topic>.md` and link it as "for X, read docs/x.md".

## Scripts over prose

If a procedure is deterministic, it belongs in `scripts/` (or a skill's own `scripts/`), not in instructions the model re-reads. A script that prints a 20-line summary beats a model reading 2,000 lines of raw output.

## Index before exploring

Read `~/dev/REPOS.md` first. It names every repo, its default branch, stack and one-line purpose, so agents don't `ls` their way around.

## Delegate reading

Broad searches, log scans and k8s sweeps run in a light-tier, read-only subagent (`explorer`, or `prod-investigator`'s scanners). Only conclusions return: file paths, line numbers, one-line findings. Never file dumps.

## Read narrowly

- Grep first, then read the matching line range, not the whole file.
- `git diff --stat` before `git diff`; diff one path at a time when large.
- Logs: `logs-errors` groups and counts; read raw lines only for the top group.
- k8s: `k8s-summary` first; `describe` only the pods it flags.

## Fresh sessions

One session per task. When a session gets long or switches topic, write `/handoff` and start fresh. State lives in files (`SPEC.md`, `handoff/`, `DECISIONS.md`), not in chat history.

## Skills load on demand

Only the frontmatter `description` is always loaded. Keep it to one sentence. The body loads when the skill is invoked; references load only when the body points at them.

## Prune monthly

- Remove or merge skills/agents/aliases that weren't used.
- Archive `done` handoff notes into `handoff/<project>/archive/`.
- Re-check `AGENTS.md` line counts: `wc -l ~/dev/*/AGENTS.md`.
