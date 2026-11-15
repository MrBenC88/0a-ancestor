# Company context

The **only** place skills and agents read company values from. Never committed (only the template is tracked).
Format: one `key: value` per line so agents can grep it. Leave unknowns as `<placeholder>`.

## Identity

company_tag: <company-tag>
ai_policy: <approved tools; may code/docs go into agent context?>

## Jira

jira_site: <https://your-site.example>
jira_projects: <KEY1, KEY2>
jira_default_project: <KEY1>
jira_access: <mcp | jira-cli | rest>
jira_token_keychain_item: <keychain service name, never the token itself>

## Source control

git_host: <github | gitlab | ...>
pr_template: <path in repo, if any>
default_reviewers: <team handles>

## Kubernetes

kube_contexts: <prod-context, staging-context>
kube_default_namespace: <namespace>
kube_prod_context: <context that requires extra care>

## Logs and observability

log_sources: <name = how to read it, e.g. k8s:app=api | file:/var/log/app.log>
dashboards: <name = url>
error_tracker: <name = url>

## Deploys

deploy_process: <one line; detail in a deploy-<company-tag> skill>
release_channel: <where releases are announced>

## Internal hosts

internal_hosts: <host1.internal, host2.corp>
