# Global instructions

Shared instructions live in `~/.config/agents/AGENTS.md`. Claude Code loads it through
`~/.claude/CLAUDE.md`; `~/.codex/AGENTS.md` and `~/.grok/AGENTS.md` symlink to it.
Keep the contents agent neutral.

## Delegation and model selection

Delegate independent tasks when doing so materially improves speed or quality.
Keep short tasks and dependent steps in the main agent, and coordinate edits so
agents do not overwrite each other's work.

When the runtime permits model selection, choose from the models it currently
exposes using their capability descriptions, without hardcoding model names in
instructions. Use the strongest reasoning model for architecture, difficult
debugging and critical reviews; a capable general model for implementation; and
a fast, efficient model for bounded searches and mechanical work. Escalate to a
more capable model when results are uncertain. If model selection is unavailable,
inherit the parent model. Use the selected model's default reasoning effort unless
the task warrants an adjustment.

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

A fast-forward is fine with someone else's changes in the tree, since git refuses
rather than overwrite them: `git fetch && git merge --ff-only @{u}`, not `git pull`,
which `pull.rebase = true` turns into a rebase. Do it before committing, then
commit and push straight away, which leaves no local commit to rebase.
