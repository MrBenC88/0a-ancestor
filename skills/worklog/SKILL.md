---
name: worklog
description: Use at the end of a work session (or when the user says "log this") to append a short summary of what shipped, was learned or is blocked to me/worklog.md.
---

# worklog

Appends a dated summary to `$ANCESTOR/me/worklog.md` (personal, never committed). `perf.md` is drafted from it monthly, so entries must carry evidence.

## Steps

1. Collect facts from the session, not memory: merged/opened PRs (`gh pr list --author @me --state all --limit 5`), commits (`git log --since=midnight --author="$(git config user.email)" --oneline`), tickets touched.
2. Write 1–5 lines, each prefixed:
   - `shipped:` user-visible or merged work, with a link (PR/ticket).
   - `learned:` something non-obvious about the codebase, a tool, or a process.
   - `blocked:` what, and who can unblock.
3. Add impact when known: a metric, a user, a time saved.
4. Append under today's heading. If `## YYYY-MM-DD` for today is missing, add it. Each line: `- HH:MM <prefix> <text>`.
   One line from a shell: `wl "shipped: <text>"`.
5. No company secrets or customer data; internal links are fine (the file is local only).
6. If something learned is reusable, also capture it per "Generalize by default" (`/create-skill`), or in `me/onboarding.md` if it's a codebase fact.

## Output

The appended lines, verbatim, and nothing else.
