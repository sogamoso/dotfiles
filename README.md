# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

```
curl -fsSL https://dotfiles.sogamo.so/install | bash
```

Safe to run multiple times. The bootstrap script is idempotent.

## Stow directory

Each folder under `stow/` is a stow package. Running `stow --target $HOME --restow <package>` symlinks its contents into `$HOME`.

```
stow/
  claude/                  # Claude Code settings, plugins, and status line
  git/                     # .gitconfig + global .gitignore
  macos/                   # macOS-only configs (stowed only on Darwin)
  mise/                    # mise config (node + ruby via latest)
  nvim/                    # Neovim plugin overrides
  ruby/                    # .gemrc, .irbrc, .default-gems
  ssh/                     # SSH client config + signing key
  zsh/                     # Shell aliases (git, gh, bundler, rails, npm)
```

### How it works

`bootstrap` runs two phases:

1. **OS setup** — dispatches by `uname -s`.
2. **Dotfiles** (`install/dotfiles/all.sh`) — cross-platform config symlinks via stow.

After both phases it drops into a fresh zsh login shell.

## CLI

A `dotfiles` command is installed to `~/.local/bin/dotfiles` for day-to-day maintenance:

| Command | Action |
|---|---|
| `dotfiles update` | Pull, sync Brewfile, restow, reload services |
| `dotfiles pull` | Git pull only |
| `dotfiles brew` | Sync Brewfile via `brew bundle` |
| `dotfiles stow` | Re-stow all packages |
| `dotfiles reload` | Restart SketchyBar and reload AeroSpace |
| `dotfiles status` | Branch, ahead/behind, dirty files |
| `dotfiles edit` | Open the repo in `$VISUAL` |

Set `$DOTFILES` to override the repo location (default: `~/Code/dotfiles`).

### Dotfiles setup

The dotfiles setup (`install/dotfiles/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `zshrc.sh` | Appends personal supplement source to `.zshrc` |
| `ssh.sh` | Ensures `~/.ssh` directory exists before stowing |
| `stow.sh` | Stows cross-platform dotfile packages into `$HOME` |
| `hushlogin.sh` | Suppresses "Last login" terminal message |
| `coderabbit.sh` | Configures git filter to strip Coderabbit config from `.gitconfig` |
| `claude-code.sh` | Installs Claude Code marketplaces, plugins, and configures claude-hud |

## Cross-platform design

The stow packages under `stow/` are cross-platform by default.

Two patterns keep configs portable:

- **Git**: `.gitconfig` uses `[include] path = ~/.config/git/config.macos`. Git silently ignores the include if the file doesn't exist (i.e. on Linux).
- **Shell**: `supplement.zsh` conditionally sources `supplement.macos.zsh` only if the file is readable. On Linux, the macOS stow package won't be installed so the file won't exist.

### macOS

Heavily inspired by [Omarchy](https://github.com/basecamp/omarchy), built on top of [Omadots](https://github.com/omacom-io/omadots). Works on a fresh macOS install with no prior tooling. The installer bootstraps everything from scratch — shell framework, packages, and dotfile symlinks.

The macOS setup (`install/macos/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `xcode.sh` | Checks for Xcode Command Line Tools, opens installer if missing, then exits for rerun after install |
| `omadots.sh` | Installs [Omadots](https://github.com/omacom-io/omadots) shell framework |
| `security.sh` | Enables SSH/firewall and applies sshd hardening |
| `onepassword.sh` | Opens 1Password for sign-in and SSH agent setup |
| `brew.sh` | Installs all packages from `Brewfile` |
| `alacritty.sh` | Installs Alacritty from latest GitHub release DMG |
| `dotfiles.sh` | Stows all dotfile packages into `$HOME` |
| `tmux.sh` | Installs TPM (tmux plugin manager) if missing |
| `preferences.sh` | macOS system defaults |
| `pwas.sh` | Installs Chrome PWAs (YouTube) |
| `sketchybar.sh` | Configures SketchyBar status bar |
| `tailscale.sh` | Starts Tailscale daemon and connects with SSH enabled |
| `aerospace.sh` | Starts AeroSpace only if not already running |
| `raycast.sh` | Opens Raycast for first-time setup |

#### Workspace layout

| Workspace | App |
|---|---|
| 1 | Ghostty, Zed, Solo |
| 2 | Chrome, Safari |
| 3 | Slack |
| 4 | Fastmail |
| 5 | Notion, Linear |
| 6 | Claude, ChatGPT, Codex, Gemini |
| 7 | WhatsApp, Discord, Telegram |
| 8 | Spotify |
| 9 | (free) |
| 10 | (scratchpad) |

#### Hotkeys

Follows [Omarchy](https://github.com/basecamp/omarchy)'s Hyprland keybinding model on macOS.

| Physical key | macOS sends | Role | Omarchy equivalent |
|---|---|---|---|
| Option | Alt/Option | Window management | Super |
| Command | Cmd | App shortcuts + tmux | Alt |

##### Navigating

| Hotkey | Action |
|---|---|
| `Option + Space` | Raycast launcher |
| `Option + Escape` | Apple menu (Raycast) |
| `Option + K` | Hotkeys cheatsheet (Raycast) |
| `Option + 1-9` | Switch to workspace 1–9 |
| `Option + S` | Switch to scratchpad (workspace 10) |
| `Option + Tab` | Next workspace |
| `Option + Shift + Tab` | Previous workspace |
| `Option + Ctrl + Tab` | Switch to former workspace |
| `Option + arrows` | Focus window left/right/up/down |
| `Option + Ctrl + arrows` | Move window within workspace |
| `Option + Shift + 1-9` | Move window to workspace and follow |
| `Option + Shift + S` | Move window to scratchpad (workspace 10) and follow |
| `Option + Shift + Cmd + 1-9` | Move window to workspace without following |
| `Option + Shift + Cmd + S` | Move window to scratchpad without following |
| `Option + W` | Close focused window |
| `Option + F` | Fullscreen |
| `Option + T` | Toggle floating/tiling |
| `Option + J` | Toggle split direction |
| `Option + L` | Toggle layout |
| `Option + - / =` | Resize width |
| `Option + Shift + - / =` | Resize height |

##### Launching apps

| Hotkey | Action |
|---|---|
| `Option + Enter` | New Ghostty window |
| `Option + Shift + Enter` | New Chrome window |
| `Option + Shift + N` | New Zed window |
| `Option + Shift + C` | Open Fastmail (calendar) |
| `Option + Shift + E` | Open Fastmail (mail) |
| `Option + Shift + G` | Open WhatsApp |
| `Option + Shift + M` | Open Spotify |
| `Option + Shift + O` | Open Obsidian |
| `Option + Shift + F` | Open Finder |
| `Option + Shift + /` | Open 1Password |
| `Option + Shift + A` | Open Claude |
| `Option + Shift + Y` | Open YouTube |
| `Option + Shift + I` | Open Notion |
| `Option + Shift + L` | Open Linear |
| `Option + Shift + D` | LazyDocker in Ghostty |
| `Option + Shift + Cmd + B` | Chrome incognito |
| `Option + Cmd + Enter` | Ghostty + tmux session |

##### System controls

| Hotkey | Action |
|---|---|
| `Option + Ctrl + L` | Lock screen |
| `Option + Ctrl + A` | Sound preferences |
| `Option + Ctrl + B` | Bluetooth preferences |
| `Option + Ctrl + W` | Wi-Fi preferences |
| `Option + Ctrl + T` | btop in Ghostty |
| `Option + Ctrl + V` | Clipboard history (Raycast) |
| `Option + Ctrl + E` | Emoji picker (Raycast) |
| `Option + Ctrl + X` | Monologue (dictation) |
| `Mic Mute (F14)` | Toggle microphone mute (Lofree mic-mute key; dead on built-in keyboard) |

##### Status notifications

| Hotkey | Action |
|---|---|
| `Option + Ctrl + Cmd + T` | Time, date, ISO week (notification) |
| `Option + Ctrl + Cmd + B` | Battery level + state (notification) |
| `Option + Ctrl + Cmd + W` | Weather from wttr.in (notification) |

##### Capture

| Hotkey | Action |
|---|---|
| `Option + Ctrl + C` | CleanShot all-in-one |
| `Cmd + Shift + 6` | CleanShot OCR text extraction (assigned inside CleanShot) |

##### Reminders

Ephemeral kitchen-timer-style reminders (die on logout/reboot).

| Hotkey | Action |
|---|---|
| `Option + Ctrl + R` | Set Reminder (Raycast — prompts for minutes + message) |
| `Option + Ctrl + Cmd + R` | Show Reminders (Raycast) |
| `Option + Ctrl + Shift + R` | Clear Reminders (Raycast) |

##### Notifications

| Hotkey | Action |
|---|---|
| `Option + ,` | Toggle Notification Center |
| `Option + Ctrl + ,` | Toggle Do Not Disturb |

##### Ghostty

| Hotkey | Action |
|---|---|
| `Ctrl + Shift + E` | Split down |
| `Ctrl + Shift + O` | Split right |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + 1-9` | Go to tab 1–9 |
| `Ctrl + Shift + Left/Right` | Previous / next tab |
| `Ctrl + Cmd + arrows` | Navigate tmux panes |
| `Ctrl + Cmd + Shift + arrows` | Resize tmux panes |

#### Manual setup guide

For the manual setup guide including Privacy & Security settings, Raycast, and Tokyo Night theming: [`docs/macos-manual-setup.md`](docs/macos-manual-setup.md).
