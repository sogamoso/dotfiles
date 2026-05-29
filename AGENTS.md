# Agent guide

Conventions for this repo. Match these over general best practices when they conflict.

## Style

- Two spaces for indentation. No tabs.
- Shebang: `#!/usr/bin/env bash` (not `#!/bin/bash` — departs from upstream Omarchy).
- `set -euo pipefail` on any script doing real work.
- Use `[[ ]]` for string/file tests, `(( ))` for numeric tests. Don't mix.
- Inside `[[ ]]`, quote string literals but not variables: `[[ $minutes =~ ^[0-9]+$ ]]`, `[[ $branch == "main" ]]`.
- Quote paths with spaces (`"$HOME/Application Support/…"`), don't escape with `\ `.
- Comments only when the *why* is non-obvious. Don't restate what well-named code already says.

## Layout

- `bootstrap` — entry point, dispatches by `uname -s`, ends in a fresh login shell.
- `install/<os>/*.sh` — per-OS install scripts. Sequenced by `install/<os>/all.sh`. Logged via `install/lib/log.sh`.
- `install/dotfiles/*.sh` — cross-platform setup that runs on every host.
- `stow/<pkg>/` — each directory is a stow package. Contents are symlinked into `$HOME`. Cross-platform by default; macOS-only goes under `stow/macos/` and is only stowed on Darwin.
- `stow/macos/.config/dotfiles/` — shared helper scripts not tied to a specific tool (e.g. `reminder.sh`, `status.sh`, `mic-mute.sh`). Invoked from AeroSpace bindings or Raycast script commands.
- `themes/<name>/colors.toml` — theme tokens. Wallpapers go under `themes/<name>/backgrounds/`.
- `docs/` — manual setup notes that can't be automated.

## Conventions

- **Omarchy parity is a stated goal.** AeroSpace bindings cross-reference their Omarchy equivalent in the trailing comment (e.g. `# Omarchy: SUPER+CTRL+R → set reminder`). Preserve this when adding bindings.
- **Modifier mapping:** in `aerospace.toml`, `alt` = physical Option key = Omarchy's SUPER, `cmd` = physical Command = Omarchy's ALT. Comments at the top of the file are the source of truth.
- **Hotkey documentation lives in three places.** Keep them in sync: README.md hotkey tables, `stow/macos/.config/raycast/script-commands/hotkeys-cheatsheet.sh`, and `docs/macos-manual-setup.md` Section 8 for hotkeys assigned inside Raycast.
- **Raycast hotkey assignments are not in dotfiles.** Raycast stores them per-machine. Document them in `docs/macos-manual-setup.md` Section 8.
- **macOS notification pattern:** `notify() { osascript -e "display notification \"\${2:-}\" with title \"\$1\""; }`. Title is required; body optional.
- **Ephemeral state** goes under `${TMPDIR:-/tmp}/dotfiles-*` (e.g. `dotfiles-reminders/`, `dotfiles-mic-mute.state`). State that should persist across reboots doesn't belong there.
- **App launchers go through `launch-or-focus.sh`.** Don't inline `open -na/-b/-a` in new bindings — call the helper so failed launches surface a notification instead of silently no-op'ing.
- **Repo maintenance via the `dotfiles` CLI.** Lives at `stow/macos/.local/bin/dotfiles`, symlinked to `~/.local/bin/dotfiles`. Subcommands: `update`, `pull`, `brew`, `stow`, `reload`, `migrate`, `migrate-new`, `status`, `edit`. Add new subcommands here rather than scattering one-off scripts.
- **Migrations** — one-shot cleanup scripts under `migrations/`, sourced (not executed) in timestamp order. Conventions and the runner contract live in `migrations/README.md`. Create new ones via `dotfiles migrate-new "description"`. Use migrations for breaking changes that need to apply to existing installs (deprecated config removal, state file moves) — not for normal install-time setup.

## Adding a new shared helper script

1. Drop it under `stow/macos/.config/dotfiles/<name>.sh`.
2. `chmod +x` it.
3. Wire the AeroSpace binding (or Raycast script command) to `$HOME/.config/dotfiles/<name>.sh`.
4. Document the hotkey in all three places above.
5. If it's user-facing, prefer a confirmation notification over silent execution.
