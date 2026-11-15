---
name: jira-write
description: Use when the user wants a Jira ticket drafted from the current context (bug, task, follow-up); shows the draft and creates it only after explicit confirmation.
---

# jira-write

## Inputs

- Context: the conversation, a SPEC, an incident summary, a PR, or the user's notes.
- From `me/context.md`: `jira_site`, `jira_default_project`, `jira_access`, `jira_token_keychain_item`.

## Steps

1. Draft:
   - **Title**: ≤ 80 chars, imperative for tasks ("Add retry to webhook sender"), symptom for bugs ("Checkout 500s when cart is empty").
   - **Description**: context (why), what (scope), out of scope. Bugs: steps to reproduce, expected, actual, evidence (log lines, links).
   - **Acceptance criteria**: 2–6 testable checkboxes.
   - **Labels / components / type / priority**: only values that already exist in the project; ask if unsure.
2. Show the draft to the user exactly as it will be created. **Stop and wait.**
3. Create only after an explicit "yes"/"create it". Access, first that works:
   1. Jira MCP connector.
   2. `jira issue create -p <PROJECT> -t <Type> -s "<title>" -b "<body>" -l <label> --no-input`
   3. REST: `POST <jira_site>/rest/api/3/issue` with a keychain token (never written to a file or shown).
4. If editing an existing ticket, show a diff of the fields you'd change and confirm the same way.

## Rules

- No secrets, customer data or credentials in tickets.
- Never bulk-create; one confirmation per ticket.

## Output

Before confirm: the draft in a fenced block, then `Create this in <PROJECT>? (yes/edit/no)`.
After create: `Created <KEY>: <title> — <url>`.
