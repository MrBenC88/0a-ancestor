# Skills

One line per skill. Maintained by /create-skill. Company skills are indexed in `company/skills/INDEX.md` (never committed).

| Skill | When to use |
| --- | --- |
| `create-skill` | After any task whose procedure could recur: capture it as a generic or company-tagged skill |
| `create-agent` | A recurring role would be better as a subagent: pick tier, tools, output; generate per-tool files |
| `caveman` | User wants terse replies / fewer tokens: compressed fragments, full accuracy; never for code, commits or PRs |
| `handoff` | Before ending a session or switching agents (write); when continuing someone's work (read) |
| `worklog` | End of a session: append shipped / learned / blocked lines to `me/worklog.md` |
| `new-project` | Starting or adopting a repo: scaffold agent files, fill `SPEC.md` with the user |
| `jira-read` | A ticket key comes up: summarize goal, AC, linked PRs, open questions |
| `jira-write` | Draft a ticket from context; create only after confirmation |
| `pr-create` | Branch ready for review: checks, conventional title, description + test plan, `gh pr create` |
| `pr-review` | Review a PR or diff against `AGENTS.md`; findings ranked by severity |
| `prod-investigate` | Something is wrong in prod: read-only symptom → scope → changes → logs → k8s → hypothesis |
| `k8s-triage` | Check cluster/namespace health via `k8s-summary`; suggest next read-only command |
| `prod-logs` | What errors is a service logging: `logs-errors`, dedupe, link to code |
| `fe-best-practices` | Frontend implementation/review: components, a11y, state, styling, testing |
| `vercel-react-best-practices` | React/Next.js performance: waterfalls, bundle, server/client, re-renders |
