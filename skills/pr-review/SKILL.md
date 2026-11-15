---
name: pr-review
description: Use when asked to review a PR or a local diff, to check it against AGENTS.md conventions and return findings ranked by severity.
---

# pr-review

Prefer running this in a fresh-context `code-reviewer` subagent so the author's reasoning doesn't bias the review.

## Inputs

- A PR number/URL (`gh pr view <n> --json title,body,files,baseRefName`; diff via `gh pr diff <n>`), or the local branch (`git diff origin/<default>...HEAD`).
- Rules: `~/dev/AGENTS.md`, the repo's `AGENTS.md`, `SPEC.md`/ticket for intent. For frontend diffs also `/fe-best-practices` and `/vercel-react-best-practices`.

## Steps

1. Read the PR title/body and the linked spec/ticket: what is it supposed to do?
2. `--stat` first; then read the diff file by file, skipping generated/lock files. Open surrounding code only where a hunk depends on it.
3. Check, in this order:
   1. **Correctness**: logic errors, edge cases (empty, null, concurrency, time zones), error handling, broken contracts/callers.
   2. **Security**: injection, authz checks, secrets, unsafe deserialization, SSRF, logging of PII.
   3. **Data**: migrations reversible, backfills, idempotency, transactions.
   4. **Tests**: do they cover the change and fail without it?
   5. **Conventions** from `AGENTS.md`; naming; dead code.
   6. **Performance**: N+1, unbounded loops/queries, bundle size (frontend).
4. Verify each finding: quote the line, explain the concrete failure (input → wrong result). Drop anything you can't make concrete.
5. Don't restate the diff; don't praise; don't nitpick style a formatter would fix.

## Severity

`blocker` breaks prod/security/data · `major` bug or missing test for core path · `minor` edge case, maintainability · `nit` optional.

## Output

```
Verdict: approve | request changes | comment
1. [blocker] path/file.ts:42 — <issue>. Fix: <one line>.
2. [major] ...
```

≤ 15 findings, most severe first. Posting comments to GitHub only after the user asks (`gh pr review <n> --comment -b …`).
