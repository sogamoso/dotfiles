# Migrations

One-shot scripts that run on `dotfiles update` (or via `dotfiles migrate` directly). Used for breaking changes that need to be applied to existing installs — removing a deprecated config file, renaming a state file, cleaning up a directory that moved.

## Conventions

- **Filename:** `<unix-timestamp>-<slug>.sh` — e.g. `1748390400-remove-old-mic-state.sh`. The timestamp determines run order.
- **Permissions:** `0644` — migrations are sourced, not executed.
- **No shebang line.**
- **First line:** an `echo` describing what the migration does. Shows up in the runner output.
- **Reference the repo via `$DOTFILES`** (set by the runner).
- **Idempotent.** Migrations should be safe to re-run, though the watermark normally prevents that.

## Creating a new migration

```
dotfiles migrate-new "Remove old mic state"
```

Creates `migrations/<timestamp>-remove-old-mic-state.sh` with a stub.

## How the runner works

`dotfiles migrate` (called by `dotfiles update`) sources every migration whose filename timestamp is greater than the watermark at `~/.local/state/dotfiles/last-migration`. The watermark advances after each successful migration; a failure halts the run and the next invocation resumes from where it stopped.

## Example

```bash
# 1748390400-remove-old-mic-state.sh

echo "Remove deprecated mic-mute state file"

rm -f "$HOME/.config/dotfiles/mic-mute.state"
```
