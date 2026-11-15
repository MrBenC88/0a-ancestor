@AGENTS.md

## Claude Code only

- Subagents live in `~/.claude/agents/`, generated from `0a-ancestor/agents/` by `gen-agents`. Edit the canonical file, then re-run `gen-agents`; never edit the generated copy.
- Skills are linked into `~/.claude/skills/` by `bootstrap.sh` (or `link-skills`). Invoke them as `/<name>`.
- Use the `model` the agent file names; don't override a tier unless the user asks.
- Prefer the Explore/explorer subagent for wide searches so file contents stay out of the main context.
