# Global agent rules

Applies to every repo under `$DEV_DIR` (default `~/dev`). A repo's own `AGENTS.md` adds to these and wins on conflict.

## Start of every task

1. Read `$DEV_DIR/REPOS.md` before exploring; it maps every repo in one page.
2. If the repo has `SPEC.md`, read it. If `handoff/<project>/LATEST.md` exists in `0a-ancestor`, read it (via `/handoff read`).
3. Company values (Jira keys, clusters, log sources, URLs, `COMPANY_TAG`) come only from `0a-ancestor/me/context.md`. Never guess them, never write them into tracked files.

## Working rules

- Small, reviewable changes. One branch per agent: `agent/<tool>-<topic>`.
- Never push, force-push, deploy, or mutate a cluster/ticket without explicit confirmation.
- Prefer existing scripts in `0a-ancestor/scripts/` over hand-rolled commands. They summarize output.
- Read-only by default for prod: `kubectl get/describe/logs` yes; `apply/delete/scale/rollout` only after the user confirms.
- Never paste tokens or secrets into files, commits, or chat. Load them from the keychain at runtime.
- Leave the tree clean: run the repo's lint/test commands (see its `AGENTS.md`) before saying "done".

## Generalize by default

After finishing any task, ask: is this reusable? If the prompt, command or procedure could recur, capture it — create a skill (a procedure) with `/create-skill` or an agent (a role) with `/create-agent` in the same session. Don't ask first; tell the user in one line what you added and where.

Decide where it goes:
- **Generic** (would work at any company): write it in generalized form, with no company names, URLs, project keys or internal tool names. Company values are read from `me/context.md` at runtime. Save to `skills/<name>/` or `agents/<name>.md`.
- **Company-specific** (depends on internal tools, services or conventions): append `-<COMPANY_TAG>` to the name (e.g. `deploy-<company-tag>`, `oncall-<company-tag>`). Save to `company/skills/<name>-<tag>/` or `company/agents/<name>-<tag>.md`, which are never committed.
- **Mixed:** split it — a generic skill plus a thin `-<tag>` skill that supplies the company specifics and calls the generic one.

Before creating, check whether an existing skill or agent covers it. If one does, extend it instead of adding a near-duplicate.

## Token budget (hard constraint)

- This file and every repo `AGENTS.md` stay ≤ 100 lines. Detail lives in `docs/`, loaded only when needed.
- Use scripts for mechanical work; their output is ≤ 50 lines (`--full` for raw).
- Delegate broad reading to a light-tier read-only subagent; only conclusions come back (≤ 15 lines).
- One session per task. Carry state across sessions and tools with `/handoff`, not long chats.
- Never dump whole files or logs into context when a grep, summary script or line range will do.
- On request ("caveman", "be brief", "less tokens") switch to `/caveman` replies; never for code, commits, PRs or handoffs.
- Full rules: `0a-ancestor/docs/token-rules.md`.

## Delegation and models

- Agents name a tier (`heavy` / `standard` / `light`); `0a-ancestor/models.md` maps tiers to models.
- When to delegate and what comes back: `0a-ancestor/agents/delegation.md`.

## Handoffs

- Notes live in `0a-ancestor/handoff/<project>/<YYYY-MM-DD>-<topic>.md`; `LATEST.md` points to the active one.
- Write and read them only through `/handoff` so the format never drifts. ≤ 60 lines.
- Before ending a session or hitting a limit, write one. When picking one up, check it against `git diff` and set `status: claimed`.

## Commits and PRs

- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
- PRs via `/pr-create`; reviews via `/pr-review`. Push with `--force-with-lease`, never plain `--force`.
- A pre-commit hook blocks commits to `0a-ancestor` that contain the company tag or internal hostnames. Don't bypass it.

## Where things go

| Thing | Location |
| --- | --- |
| Generic skill / agent | `0a-ancestor/skills/<name>/`, `0a-ancestor/agents/<name>.md` |
| Company skill / agent | `0a-ancestor/company/skills/<name>-<tag>/`, `company/agents/<name>-<tag>.md` |
| Alias or shell function | `0a-ancestor/shell/<theme>.zsh` (company ones in `shell/local.zsh`) |
| Script | `0a-ancestor/scripts/<name>` |
| Personal notes | `0a-ancestor/me/*.md` (never committed) |
| How to add any of these | `0a-ancestor/docs/adding-things.md` |
