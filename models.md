# Model tiers

Agent files name a **tier**, never a model. `scripts/gen-agents` reads the table below, so changing a model is a one-line edit followed by `gen-agents`.

| tier | claude | codex | codex_effort | use for |
| --- | --- | --- | --- | --- |
| heavy | claude-opus-5-5 | gpt-6-sol | high | Planning, architecture, specs, final review, incident hypotheses |
| standard | claude-opus-5-5 | gpt-6-sol | medium | Scoped implementation from a plan |
| light | claude-sonnet-5-5 | gpt-6-luna | xhigh | Search, exploration, renames, test stubs, boilerplate, log scanning |

Notes:

- **standard → Claude:** swap to `claude-sonnet-5-5` to save tokens.
- **light → Claude:** `claude-haiku-5-5` is the cheaper alternative.
- **Codex Astra** is used only by explicit escalation, never by a tier default.
- Fable is excluded.
- Smaller models need more effort, which is why light-tier Codex runs Luna at `xhigh`.
- Codex model IDs follow the names in your Codex install; check them with `codex --help` or its docs and fix the column if they differ.
