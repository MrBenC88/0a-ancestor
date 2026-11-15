---
name: jira-read
description: Use when a Jira ticket key or link comes up, to fetch the ticket(s) and summarize goal, acceptance criteria, linked PRs and open questions.
---

# jira-read

Read-only. Never edits a ticket.

## Inputs

- Ticket key(s) (e.g. `ABC-123`) or a search ("my open tickets in the current sprint").
- From `me/context.md`: `jira_site`, `jira_projects`, `jira_default_project`, `jira_access`, `jira_token_keychain_item`.

## Access, in order

Use the first that works; say which one you used.

1. **Jira MCP connector**, if one is available in this session.
2. **jira-cli**: `jira issue view <KEY> --plain --comments 5` · search: `jira issue list -q '<JQL>' --plain --columns key,summary,status,assignee`.
3. **REST via curl** with a token from the keychain (never write it to a file or echo it):
   ```sh
   tok="$(security find-generic-password -s "<jira_token_keychain_item>" -w)"   # macOS
   curl -fsS -u "<email>:$tok" "<jira_site>/rest/api/3/issue/<KEY>?fields=summary,status,description,issuelinks,assignee,labels,customfield_*"
   ```
   Pipe through `jq` to keep only needed fields; don't dump raw JSON into context.

If none works, ask the user to paste the ticket text.

## Steps

1. Fetch the ticket(s). For a search, cap at 10 results.
2. Extract acceptance criteria: an "Acceptance criteria" section, checklists, or "should/must" sentences. If there are none, say so — don't invent them.
3. Find linked PRs: issue links, development panel, or `gh pr list --search "<KEY>" --state all`.
4. List open questions: ambiguities, missing AC, conflicting comments, unknown owners.

## Output

Per ticket, ≤ 12 lines:

```
<KEY> · <status> · <assignee> — <summary>
Goal: <one line>
AC:
- [ ] ...
PRs: <links or none>
Open questions:
- ...
```

For a search: one line per ticket (`KEY · status · summary`).
