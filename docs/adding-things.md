# Adding things

How to add each kind of thing so growth stays tidy. Rule zero: **generic goes in tracked files; company-specific gets a `-<company-tag>` suffix and lives in `company/`, `shell/local.zsh` or `me/context.md`.**

## Alias or shell function

Add it to the themed file (`shell/aliases.zsh`, `git.zsh`, `k8s.zsh`, `agents.zsh`, `functions.zsh`) with a `# desc:` comment on the line directly above. The `aliases` command reads these.

```zsh
# desc: show the five biggest files in the current dir
alias big='du -ah . | sort -rh | head -5'
```

- Functions over aliases when it takes arguments or needs logic.
- No network calls, subshells to slow tools, or `brew --prefix` at load time. Startup budget: < 50 ms for all of `init.zsh` (`time zsh -i -c exit`).
- Company-specific: put it in `shell/local.zsh`, named with the tag (`deploy-<company-tag>`).

## Script

`scripts/<name>`, executable (`chmod +x`, and `git update-index --chmod=+x` if committing from Windows).

```bash
#!/usr/bin/env bash
# desc: one line, shown by `aliases`
set -euo pipefail
. "$(dirname "$0")/lib/common.sh"
```

- `--help` prints usage. Summary output ≤ 50 lines; `--full` for raw.
- Anything destructive: `--dry-run` support **and** a confirm prompt (`--yes` to skip).
- Bash 3.2-compatible (macOS default): no associative arrays, `mapfile`, `wait -n` or `${var,,}`.
- Passes `shellcheck`.

## Skill

Always via `/create-skill`. It decides generic vs company vs mixed, scaffolds `SKILL.md`, moves mechanical steps into a script and adds the row to `skills/INDEX.md`.

Hand-written skills must still have: frontmatter `name` + one-sentence `description`, body ≤ ~150 lines, no hardcoded company values (read `me/context.md`), and a closing **Output** section.

## Agent

Always via `/create-agent`. Canonical file in `agents/<name>.md` with frontmatter `name`, `description`, `tier`, `tools`, `output`; then `gen-agents`. Never edit the generated copies in `~/.claude/agents` or `~/.codex/agents`.

`tools` is a comma list of capabilities that `gen-agents` maps per tool:

| Capability | Claude Code tools | Codex sandbox |
| --- | --- | --- |
| `read` | Read, Grep, Glob | read-only |
| `write` | Edit, Write | workspace-write |
| `shell` | Bash | (inherits) |
| `web` | WebFetch, WebSearch | (inherits) |
| `mcp` | no restriction (inherits all, incl. MCP) | (inherits) |

## Template

Add to `templates/`; if `new-project` should create it, add one line to the file list in `scripts/new-project`.

## Company-specific anything

Name it with `-<company-tag>` and keep it in `company/skills/`, `company/agents/`, `shell/local.zsh` or `me/context.md`. `.gitignore`, `.git/info/exclude` and the pre-commit hook all block it from commits.

## Harvesting from work

When something built at work proves generic, rewrite it clean on a personal machine and commit it here. Never copy company code or text.
