---
name: handoff
description: Use before ending a session, hitting a context/usage limit, or switching agents (write), and at the start of a session that continues someone's work (read).
---

# handoff

`0a-ancestor/handoff/` is the single source of truth for work passed between agents (Claude ↔ Codex ↔ Copilot) or across sessions. Always use this skill so the format never drifts.

Paths (`$ANCESTOR` = the `0a-ancestor` dir, usually `~/dev/0a-ancestor`):

- Note: `$ANCESTOR/handoff/<project>/<YYYY-MM-DD>-<topic>.md`
- Pointer: `$ANCESTOR/handoff/<project>/LATEST.md` → symlink to the active note
- `<project>` = basename of the repo's git toplevel.

## Write

1. Gather facts, don't recall them: `git branch --show-current`, `git rev-parse --short HEAD`, `git status --short`, `git diff --stat`.
2. Copy `$ANCESTOR/templates/handoff.md` to the note path (topic = 2–4 kebab-case words). If a note for the same topic exists today, update it instead.
3. Fill the frontmatter:
   - `from`: `<tool>-<model>` (e.g. `claude-opus-5.5`, `codex-sol`)
   - `to`: intended receiver, or `any`
   - `status: open`
   - `branch`, `commit`: from step 1
4. Fill sections, terse, ≤ 60 lines total:
   - **Goal** — one or two lines; link `SPEC.md` / ticket.
   - **Done** — what is finished and verified.
   - **Next (ordered)** — concrete steps the receiver can start on immediately.
   - **Blockers / decisions needed** — questions for the user, with options.
   - **Files touched** — paths only.
   - **How to verify** — exact commands.
5. Point LATEST at it: `ln -sfn <note-file-name> $ANCESTOR/handoff/<project>/LATEST.md` (relative target, run from that dir). If symlinks fail, copy the note to `LATEST.md`.
6. Commit or push nothing in `handoff/` — it's gitignored on purpose.

## Read / claim

1. `cat $ANCESTOR/handoff/<project>/LATEST.md` (shell: `handoff`).
2. Check it against reality: `git log --oneline -5`, `git diff --stat <commit>..HEAD`, current branch. Note any drift.
3. Set `status: claimed` and `to:` yourself in the note.
4. Work on your own branch `agent/<tool>-<topic>`; never edit files another open note lists as in progress.
5. When finished, set `status: done` and write a new note if anything remains.

## Archive (monthly)

Move notes with `status: done` into `handoff/<project>/archive/`; keep LATEST pointing at the newest open note (or remove it).

## Output

- Write: `Handoff → handoff/<project>/<file> (status open, next: <first Next item>).`
- Read: the note's Goal, Next and Blockers in ≤ 10 lines, plus `Drift: none` or what differs from `git`.
