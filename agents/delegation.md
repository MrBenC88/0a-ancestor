# Delegation

When to hand work to a subagent, and what comes back. Agents name a tier; `models.md` maps tiers to models.

## Delegate

- **Parallelizable work**: independent searches, one log source per scanner, tests for separate modules.
- **Read-heavy exploration**: "where is X", "how does Y flow", "which repos use Z" → `explorer`.
- **Log and k8s scanning** → `explorer` running `logs-errors` / `k8s-summary`, led by `prod-investigator`.
- **Reviews that need fresh eyes** → `code-reviewer`, which has none of the author's context by design.

## Don't delegate

- Small edits you can make in one or two tool calls.
- Anything that depends on reasoning in the current conversation; re-explaining it costs more than doing it.
- Decisions the user must make.

## Contract

- Give the subagent: the goal, the exact question, scope limits, and what to return.
- Subagents reply in **≤ 15 lines**: conclusions, `path:line` refs, next step. Never file dumps.
- Detail that must survive goes to `handoff/` via `/handoff`.
- Two agents never edit the same files at once; each works on its own `agent/<tool>-<topic>` branch.

## Typical chains

| Task | Chain |
| --- | --- |
| New feature | `planner` → user approves SPEC → `implementer` → `test-writer` → `code-reviewer` → `pr-author` |
| Bug fix | `explorer` (locate) → `test-writer` (failing test) → `implementer` → `code-reviewer` |
| Incident | `prod-investigator` + parallel `explorer` scans → user decides mitigation |
| Ticket work | `jira-scribe` (read) → `planner` or `implementer` |

## Roster

Maintained by /create-agent (generic agents only; company agents live in `company/agents/`).

| Agent | Tier | When |
| --- | --- | --- |
| `planner` | heavy | Plans, architecture, SPEC drafts; read-only |
| `implementer` | standard | Scoped implementation from a plan; leaves a handoff |
| `code-reviewer` | heavy | Fresh-context review; ranked findings |
| `explorer` | light | Read-heavy search; conclusions only |
| `test-writer` | light | Unit/integration/regression tests |
| `prod-investigator` | heavy | Read-only incident lead; delegates scans |
| `pr-author` | standard | Push branch, open PR with description and test plan |
| `jira-scribe` | light | Read tickets, draft new ones; create after confirm |
