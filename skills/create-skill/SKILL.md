---
name: create-skill
description: Use after finishing any task whose prompt, command or procedure could recur, to capture it as a reusable skill (generic or company-tagged).
---

# create-skill

Turns a repeated procedure into a skill. This runs **by default** (see "Generalize by default" in `AGENTS.md`): don't ask first, just tell the user in one line what you added and where.

## 1. Check for an existing skill

- Read `skills/INDEX.md` and `company/skills/INDEX.md` (if present).
- If an existing skill covers ≥ 70% of it, **extend that skill** instead of adding a near-duplicate. Stop here.

## 2. Classify

| If it… | It is | Name | Location |
| --- | --- | --- | --- |
| would work at any company | generic | `<name>` | `skills/<name>/` |
| depends on internal tools, services, URLs or conventions | company | `<name>-<COMPANY_TAG>` | `company/skills/<name>-<tag>/` |
| is a generic procedure with company specifics | mixed | both | generic skill + thin `-<tag>` skill that supplies values and calls the generic one |

`COMPANY_TAG` comes from `me/context.md` (`company_tag:`). Never write the real tag into a tracked file.

## 3. Scaffold

```sh
skills/create-skill/scripts/scaffold skill <name> --desc "Use when …; does …."
skills/create-skill/scripts/scaffold skill <name> --company --desc "…"   # company version
```

The script refuses duplicates, appends the row to the right `INDEX.md`, links the skill into every tool's skills dir, and warns about similar names.

## 4. Write the body

- **description** (frontmatter): one sentence that says **when** to use it. This is the only part always loaded.
- **Generic form**: no company names, URLs, project keys or internal tool names. Read them at runtime from `me/context.md` (`key: value` lines).
- **Steps**: numbered, imperative, minimal.
- **Deterministic steps → a script** in `skills/<name>/scripts/` (bash, `set -euo pipefail`, `--help`, ≤ 50 lines of output). The skill calls the script instead of describing the commands.
- **Long reference → `references/<topic>.md`**, linked from the body ("for X, read references/x.md").
- Body ≤ ~150 lines.
- End with an **Output** section stating exactly what the skill returns.

## 5. Verify

- `head -5 skills/<name>/SKILL.md` shows valid frontmatter.
- For a company skill: `git status --short` must **not** list it.
- `wc -l skills/<name>/SKILL.md` ≤ 150.

## Output

One line: `Added skill <name> → <path> (<generic|company|mixed>).` If you extended an existing skill instead: `Extended <name>: <what changed>.`
