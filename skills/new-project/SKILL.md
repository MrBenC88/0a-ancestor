---
name: new-project
description: Use when starting a new repo or adopting an existing one, to scaffold AGENTS.md, CLAUDE.md, SPEC.md and CHANGELOG.md and fill SPEC.md with the user.
---

# new-project

## Steps

1. Run the scaffold (idempotent; skips existing files):
   ```sh
   new-project <path> [--decisions] [--copilot]
   ```
   It detects build/test/lint commands for `AGENTS.md` from `package.json`, `Makefile`, `go.mod`, `Cargo.toml`, `pyproject.toml`.
2. Complete `AGENTS.md` (≤ 100 lines): verify the detected commands actually run; add layout (one line per top-level dir), conventions an agent would get wrong, and pitfalls. Use an `explorer` subagent for the survey; only conclusions come back.
3. Fill `SPEC.md` **with the user** — ask, don't invent:
   - Summary (what and why), goals, non-goals
   - Acceptance criteria as checkboxes
   - Phased plan (deliverables + "done when")
   - Open questions
   Ask at most 3–5 questions at once; draft the rest and mark assumptions with `(assumed)`.
4. Run `index-repos` so `~/dev/REPOS.md` includes the repo.
5. If the user approves, commit: `docs: add agent files and spec`.

## Rules

- Never overwrite an existing `AGENTS.md` or `SPEC.md`; propose edits instead.
- Company values go in `me/context.md`, not the repo, unless the repo is company-owned and the value is already public within it.

## Output

```
Scaffolded <project>: created <files>; skipped <files>.
SPEC.md: <n> acceptance criteria, <n> open questions.
```
