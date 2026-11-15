# 0a-ancestor

A public template that gives any `~/dev/` directory a full agent and shell setup: shared agent rules, portable skills, reusable agents, a file-based handoff protocol, token-saving scripts and zsh config.

It sits **beside** your project repos (`0a` sorts it first). Bootstrap links its rules into `~/dev/`, so every sibling repo inherits them. It works with Claude Code, Codex, GitHub Copilot and Cursor.

**No personal or company data is ever committed.** Real values live in gitignored files (`me/*.md`, `shell/local.zsh`, `company/`), and a pre-commit hook blocks the company tag and internal hostnames.

## Quickstart

```sh
cd ~/dev && git clone https://github.com/MrBenC88/0a-ancestor.git
cd 0a-ancestor && git remote rename origin upstream   # never push from a work machine
./bootstrap.sh --brew        # install CLI tools, link everything
./bootstrap.sh --check       # should be all green
exec zsh                     # then: gtd, aliases
```

Then fill `me/context.md` (company values) and `me/onboarding.md` during week one. Keep `~/dev` out of personal cloud sync.

## What you get

| Path | What |
| --- | --- |
| `AGENTS.md`, `CLAUDE.md` | Global agent rules, linked into `~/dev/` |
| `skills/` | Portable `SKILL.md` skills, linked into each tool's skills dir |
| `agents/` | Canonical agent definitions; `gen-agents` writes Claude and Codex copies |
| `models.md` | Tier → model map (one-line edit to change models) |
| `scripts/` | `gpa`, `gst-all`, `gclean`, `new-project`, `index-repos`, `gen-agents`, `link-skills`, `k8s-summary`, `logs-errors` |
| `shell/` | zsh config, sourced via one line in `~/.zshrc` |
| `templates/` | Per-repo `AGENTS.md`, `SPEC.md`, `CHANGELOG.md`, `DECISIONS.md`, handoff note |
| `me/` | Personal templates: worklog, brag doc, onboarding, people, context |
| `handoff/` | Cross-agent handoff notes (gitignored) |
| `company/` | Company-specific skills and agents (gitignored) |
| `docs/` | Loaded on demand: token rules, how to add things |

## Bootstrap

`./bootstrap.sh` is idempotent and never overwrites your files (conflicts are backed up to `*.bak.<timestamp>`).

| Flag | Does |
| --- | --- |
| *(none)* | Link and generate everything |
| `--check` | Report status, change nothing; non-zero exit if anything is off |
| `--dry-run` | Print what it would do |
| `--brew` | Also run `brew bundle --file=Brewfile` |

## Day to day

- `aliases` lists every alias, function and script this repo adds.
- `gpa` pulls every repo's default branch safely; `gst-all` shows them all on one screen.
- `new-project` scaffolds `AGENTS.md`, `SPEC.md` and friends in a repo.
- In an agent session: `/handoff`, `/worklog`, `/pr-create`, `/prod-investigate`, `/create-skill`.

## Growing it

See [docs/adding-things.md](docs/adding-things.md). Anything generic goes in tracked files; anything company-specific gets a `-<company-tag>` suffix and lives in `company/`, `shell/local.zsh` or `me/context.md`. When something built at work proves generic, rewrite it clean on a personal machine and commit it here. Never copy company code or text.

## Requirements

macOS + zsh first. Scripts are bash (3.2-compatible) with `set -euo pipefail` and also run on Linux.
