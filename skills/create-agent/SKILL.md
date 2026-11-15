---
name: create-agent
description: Use when a recurring role (reviewer, scanner, responder) would be better as a dedicated subagent; picks tier, tools and output contract, then generates per-tool files.
---

# create-agent

Same rules as `/create-skill`, for agents. A **skill** is a procedure; an **agent** is a role with its own context, tools and model tier.

## 1. Check for an existing agent

- Read the roster at the end of `agents/delegation.md` and `ls company/agents/`.
- If one covers the role, extend it. Stop here.

## 2. Classify

Generic → `agents/<name>.md`. Company-specific → `company/agents/<name>-<COMPANY_TAG>.md` (never committed). Mixed → generic agent plus a thin `-<tag>` agent that adds company context. Tag from `me/context.md`.

## 3. Pick the contract

| Field | Choose |
| --- | --- |
| `tier` | `heavy` planning/review/hypotheses · `standard` scoped implementation · `light` search/scan/boilerplate (see `models.md`) |
| `tools` | smallest set: `read`, `write`, `shell`, `web`, `mcp` (mapping in `docs/adding-things.md`) |
| `output` | one line: what it returns, ≤ 15 lines; detail goes to `handoff/` |

Read-only roles never get `write`. Anything that could touch prod gets `read, shell` plus an explicit "no mutations" rule in the body.

## 4. Scaffold and generate

```sh
skills/create-skill/scripts/scaffold agent <name> --tier light --tools read,shell \
  --desc "Use when …" --output "…"
# add --company for a company agent
```

This writes the canonical file, adds a roster row (generic only) and runs `gen-agents`, producing `~/.claude/agents/<name>.md` and `~/.codex/agents/<name>.toml`.

## 5. Write the body

- First line: who the agent is, in one sentence.
- **Job**: 3–6 bullets. **Rules**: constraints (read-only, confirm before X, company values from `me/context.md`).
- **Output**: the exact shape of the reply.
- Edit only `agents/<name>.md`, then re-run `gen-agents`. Never edit generated copies.

## Output

One line: `Added agent <name> (tier <tier>, tools <tools>) → <path>; generated for <tools found>.`
