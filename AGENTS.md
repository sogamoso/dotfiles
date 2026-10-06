# Agent guide

Conventions for this repo. Match these over general best practices when they conflict.

## Style

- Two spaces for indentation. No tabs.
- Shebang: `#!/usr/bin/env bash` (not `#!/bin/bash` — departs from upstream Omarchy).
- `set -euo pipefail` on any script doing real work. SketchyBar plugins and AeroSpace event hooks are exempt: they run on every tick or focus change and are written to carry on past a failed lookup, where strict mode would leave a bar item blank or drop the event.
- Use `[[ ]]` for string/file tests, `(( ))` for numeric tests. Don't mix.
- Inside `[[ ]]`, quote string literals but not variables: `[[ $minutes =~ ^[0-9]+$ ]]`, `[[ $branch == "main" ]]`.
- Quote paths with spaces (`"$HOME/Application Support/…"`), don't escape with `\ `.
- Comments only when the *why* is non-obvious. Don't restate what well-named code already says.

## Layout

- `bootstrap` — entry point, dispatches by `uname -s`, ends in a fresh login shell.
- `install/<os>/*.sh` — per-OS install scripts. Sequenced by `install/<os>/all.sh`. Logged via `install/lib/log.sh`.
- `install/dotfiles/*.sh` — cross-platform setup that runs on every host.
- `install/lib/*.sh` — helpers sourced by the install scripts, never run directly. `log.sh` for output, `stow-orphans.sh` to clear links left behind when this checkout moves, `take-ownership.sh` to move aside real files that other installers leave where a stow package wants a symlink, `link-skills.sh` for the skill linking and plugin installs behind `install/dotfiles/skills.sh`. All stowing happens in `install/dotfiles/stow.sh`, which each OS's `all.sh` runs as soon as the tools it needs are installed; its ownership guards sit next to the package list for the OS they apply to.
- `stow/<pkg>/` — each directory is a stow package. Contents are symlinked into `$HOME`. Cross-platform by default; macOS-only goes under `stow/macos/` and is only stowed on Darwin, Omarchy-only under `stow/linux/` and only stowed on Linux. One exception: `stow/zsh/` is macOS-only but its own package, paired with the bash config under `stow/linux/` (see the shell pairs below). Zsh config that only makes sense on macOS, as opposed to zsh in general, goes in `stow/macos/.config/zsh/`.
- **Omarchy customizations follow Omarchy's own convention.** Its file-layout doc reserves `~/.config/omarchy/` for "files a user may intentionally version in a dotfile manager" — user themes, hooks, shell layout, plugins, themed template overrides — and `~/.config/hypr/*.lua` for Hyprland. Generated state under `~/.local/state/omarchy/` is never versioned. Keybinding overrides go in `~/.config/hypr/bindings.lua` through `o.bind`, `o.rebind` and `hl.unbind`; don't fork Omarchy's defaults, override them.
- `stow/macos/.config/dotfiles/` — shared helper scripts not tied to a specific tool (e.g. `reminder.sh`, `status.sh`, `mic-mute.sh`). Invoked from AeroSpace bindings or Raycast script commands.
- Agent skills are not kept in this repo. `install/dotfiles/skills.sh` installs the private `sogamoso/skills` as a plugin in both agents and links the ui.sh stubs from the private `sogamoso/uidotsh-archive` checkout into both `~/.claude/skills` and `~/.codex/skills`. Third-party plugins come from `claude-code.sh` and `codex.sh`. Never add ui.sh material to this public repo: its license forbids redistributing it.
- `themes/<name>/colors.toml` — theme tokens. Nothing reads them automatically: they're the reference palette for setting custom themes by hand in apps that don't ship the theme (Slack, for one). Don't delete them for lack of references. Wallpapers go under `themes/<name>/backgrounds/`.
- `docs/` — manual setup notes that can't be automated.

## Conventions

- **Omarchy parity is a stated goal.** AeroSpace bindings cross-reference their Omarchy equivalent in the trailing comment (e.g. `# Omarchy: SUPER+CTRL+R → set reminder`). Preserve this when adding bindings.
- **Modifier mapping:** in `aerospace.toml`, `alt` = physical Option key = Omarchy's SUPER, `cmd` = physical Command = Omarchy's ALT. Comments at the top of the file are the source of truth.
- **Hotkeys live in three places — keep them in sync on both add AND remove.** Adding without updating all of them produces phantom bindings; removing without updating all of them produces phantom docs. The three:
  1. `stow/macos/.config/aerospace/aerospace.toml` — the binding itself (skip when the hotkey is assigned inside Raycast instead of AeroSpace).
  2. `README.md` — hotkey reference tables. The Raycast cheatsheet (`hotkeys-cheatsheet.sh`) renders itself from these at run time, one section per `#####` heading, so it needs no edit; keep hotkeys in tables there, since prose is skipped.
  3. `docs/macos-manual-setup.md` Section 7 — for hotkeys assigned inside specific apps (Raycast, CleanShot, etc.) that are per-machine, not in dotfiles.
- **App-level hotkey assignments are not in dotfiles.** Raycast and CleanShot store them per-machine. Document them in `docs/macos-manual-setup.md` Section 7 under the appropriate subsection.
- **macOS notification pattern:** set `GROUP_ID="dotfiles-<script>"`, then `source "$HOME/.config/dotfiles/lib/notify.sh"` and call `notify <title> [message] [terminal-notifier flags...]`. Title is required; body optional. The group makes a repeat replace the previous banner instead of stacking. Don't call `terminal-notifier` or `osascript -e 'display notification'` directly.
- **Ephemeral state** goes under `${TMPDIR:-/tmp}/dotfiles-*` (e.g. `dotfiles-reminders/`, `dotfiles-mic-mute.state`). State that should persist across reboots doesn't belong there.
- **App launchers go through `launch-or-focus.sh`.** Don't inline `open -na/-b/-a` in new bindings — call the helper so failed launches surface a notification instead of silently no-op'ing.
- **Shell configs come in pairs — zsh for macOS, bash for Omarchy.** The two
  machines run different shells, so every shell change has to be considered for
  both. Before finishing a change to one side, check whether it *can* port
  (does it rely on shell-specific syntax?) and whether it *should* (does the
  other OS already provide it?). The pairs:
  1. `stow/zsh/.config/zsh/supplement.zsh` ↔ `stow/linux/.config/bash/supplement.bash`
  2. `stow/zsh/.config/zsh/aliases/<name>.zsh` ↔ `stow/linux/.config/bash/aliases/<name>.bash`

  Alias file bodies are kept **byte-identical** across the pair so that
  `diff <(cat stow/zsh/.config/zsh/aliases/git.zsh) stow/linux/.config/bash/aliases/git.bash`
  shows real drift and nothing else. Don't add a header comment to one side only.

  Deliberate exceptions, which are *not* drift:
  - `herdr.zsh` has no bash counterpart. It is a hand-port of Omarchy's own
    helpers, and Omarchy ships `default/bash/fns/herdr` natively — porting it
    back would shadow the real thing and go stale every release.
  - `supplement.zsh` keeps `HOMEBREW_AUTO_UPDATE_SECS` (macOS only), the
    `compinit` block and `zsh-you-should-use` (zsh only), and the
    `supplement.macos.zsh` source (macOS only). `supplement.bash` omits all
    four; Omarchy supplies completions and its own alias layer.

  A new alias file defaults to **both** sides. Only skip the bash copy when
  Omarchy already provides the same thing.

- **Repo maintenance via the `dotfiles` CLI.** Lives at `stow/macos/.local/bin/dotfiles`, symlinked to `~/.local/bin/dotfiles`. Subcommands: `update`, `pull`, `brew`, `stow`, `reload`, `status`, `edit`. Add new subcommands here rather than scattering one-off scripts.

## Adding a new shared helper script

1. Drop it under `stow/macos/.config/dotfiles/<name>.sh`.
2. `chmod +x` it.
3. Wire the AeroSpace binding (or Raycast script command) to `$HOME/.config/dotfiles/<name>.sh`.
4. Document the hotkey in all three places above.
5. If it's user-facing, prefer a confirmation notification over silent execution.
