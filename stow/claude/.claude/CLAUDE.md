# Global instructions

Read by Claude Code as `~/.claude/CLAUDE.md`, by Codex as `~/.codex/AGENTS.md` and
by Grok as `~/.grok/AGENTS.md` — the codex and grok packages symlink back to this
file. Keep the contents agent neutral.

## Commits

- Subject line in the imperative mood ("Add", "Drop", "Fix" — not "Added" or "Adds").
- Body is prose explaining *why* the change was made, not a restatement of the diff.
- No trailers: no `Co-Authored-By`, no `Generated with`. Claude Code's
  `settings.json` already blanks commit and PR attribution; this covers the rest.

## Project instruction files

`AGENTS.md` is the canonical one in any repo — every agent reads it. `CLAUDE.md`
is a pointer to it, never a second copy.

- Asked to write or update a project's instructions, `/init` included: the
  content goes in `AGENTS.md`.
- `CLAUDE.md` holds the single line `@AGENTS.md` and nothing else. Create it that
  way when it's missing; when it already carries content, move that content into
  `AGENTS.md` and reduce it to the pointer.
- Never leave the two as parallel copies — they drift.

## Shared checkouts

Other agent sessions may be working in the same checkout. Uncommitted changes you
didn't make are someone else's work in progress: don't stash, reset, check out or
pull over them (`git pull --autostash` included), and commit only the files you
changed. When a pull or rebase needs a clean tree, stop and say so.
