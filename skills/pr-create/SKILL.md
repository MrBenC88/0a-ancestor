---
name: pr-create
description: Use when work on a branch is ready for review, to check the branch, write a conventional title and a description with test plan from the diff, and open the PR with gh.
---

# pr-create

## Steps

1. **Branch check**
   - Not on the default branch (detect: `git symbolic-ref --short refs/remotes/origin/HEAD`). If you are, create `agent/<tool>-<topic>` or ask for a name.
   - Tree clean (`git status --short`); if not, ask whether to commit or leave out.
   - Up to date: `git fetch origin && git rev-list --count HEAD..origin/<default>`. If behind, offer `gup` (rebase) before opening.
   - Lint/tests from the repo's `AGENTS.md` pass. If they fail, stop and report.
2. **Context**: `git log --oneline origin/<default>..HEAD`, `git diff --stat origin/<default>...HEAD`, then read only the hunks you need. Pull the goal from `SPEC.md`, the handoff note, or the ticket (`/jira-read <KEY>` if a key is in the branch name or commits).
3. **Title**: conventional commit form, ≤ 72 chars: `feat(scope): add …`, `fix: …`. Include the ticket key if the team uses it (`me/context.md`).
4. **Description** (use the repo's PR template if `.github/pull_request_template.md` exists):
   ```
   ## Why
   <1–3 lines; link ticket/spec>
   ## What
   - <change, by area>
   ## Test plan
   - [ ] <exact commands run, and results>
   - [ ] <manual checks>
   ## Risk / rollout
   <migrations, flags, backwards compat; "low" if none>
   ```
5. **Open**: `git push -u origin HEAD` then `gh pr create --title "<title>" --body-file <tmpfile> [--draft] [--reviewer <from me/context.md>]`. Use `--draft` unless the user said it's ready.
6. Print the URL. Don't merge.

## Rules

- Never force-push someone else's branch; on your own, only `--force-with-lease`.
- No secrets, internal hostnames or customer data in the description of a public repo.

## Output

```
PR #<n> (<draft|ready>): <title>
<url>
Checks: <lint/test result>
```
