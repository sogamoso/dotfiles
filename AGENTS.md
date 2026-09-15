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
- **Hotkeys live in four places — keep them in sync on both add AND remove.** Adding without updating all of them produces phantom bindings; removing without updating all of them produces phantom docs. The four:
  1. `stow/macos/.config/aerospace/aerospace.toml` — the binding itself (skip when the hotkey is assigned inside Raycast instead of AeroSpace).
  2. `README.md` — hotkey reference table.
  3. `stow/macos/.config/raycast/script-commands/hotkeys-cheatsheet.sh` — in-Raycast cheatsheet.
  4. `docs/macos-manual-setup.md` Section 8 — for hotkeys assigned inside specific apps (Raycast, CleanShot, etc.) that are per-machine, not in dotfiles.
- **App-level hotkey assignments are not in dotfiles.** Raycast and CleanShot store them per-machine. Document them in `docs/macos-manual-setup.md` Section 8 under the appropriate subsection.
- **macOS notification pattern:** `notify() { osascript -e "display notification \"\${2:-}\" with title \"\$1\""; }`. Title is required; body optional.
- **Ephemeral state** goes under `${TMPDIR:-/tmp}/dotfiles-*` (e.g. `dotfiles-reminders/`, `dotfiles-mic-mute.state`). State that should persist across reboots doesn't belong there.
- **App launchers go through `launch-or-focus.sh`.** Don't inline `open -na/-b/-a` in new bindings — call the helper so failed launches surface a notification instead of silently no-op'ing.
- **Repo maintenance via the `dotfiles` CLI.** Lives at `stow/macos/.local/bin/dotfiles`, symlinked to `~/.local/bin/dotfiles`. Subcommands: `update`, `pull`, `brew`, `stow`, `reload`, `status`, `edit`. Add new subcommands here rather than scattering one-off scripts.

## Adding a new shared helper script

1. Drop it under `stow/macos/.config/dotfiles/<name>.sh`.
2. `chmod +x` it.
3. Wire the AeroSpace binding (or Raycast script command) to `$HOME/.config/dotfiles/<name>.sh`.
4. Document the hotkey in all three places above.
5. If it's user-facing, prefer a confirmation notification over silent execution.
