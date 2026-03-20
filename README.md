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

After both phases it checks Tailscale status and drops into a fresh zsh login shell.

### Dotfiles setup

The dotfiles setup (`install/dotfiles/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `zshrc.sh` | Appends personal supplement source to `.zshrc` |
| `ssh.sh` | Ensures `~/.ssh` directory exists before stowing |
| `stow.sh` | Stows cross-platform dotfile packages into `$HOME` |
| `hushlogin.sh` | Suppresses "Last login" terminal message |
| `coderabbit.sh` | Configures git filter to strip Coderabbit config from `.gitconfig` |

## Cross-platform design

The stow packages under `stow/` are cross-platform by default.

Two patterns keep configs portable:

- **Git**: `.gitconfig` uses `[include] path = ~/.config/git/config.macos`. Git silently ignores the include if the file doesn't exist (i.e. on Linux).
- **Shell**: `supplement.zsh` conditionally sources `supplement.macos.zsh` only if the file is readable. On Linux, the macOS stow package won't be installed so the file won't exist.

### macOS

Works on a fresh macOS install with no prior tooling. The installer bootstraps everything from scratch — shell framework, packages, and dotfile symlinks.

Heavily inspired by [Omarchy](https://github.com/basecamp/omarchy), built on top of [Omadots](https://github.com/omacom-io/omadots).

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
| `pwas.sh` | Installs Chrome PWAs (Gmail, Calendar, Meet) |
| `sketchybar.sh` | Configures SketchyBar status bar |
| `aerospace.sh` | Starts AeroSpace only if not already running |
| `raycast.sh` | Opens Raycast for first-time setup |

#### Workspace layout

| Workspace | App |
|---|---|
| 1 | Ghostty |
| 2 | Chrome, Meet |
| 3 | Slack |
| 4 | Gmail |
| 5 | Todoist, Calendar |
| 6 | Notion, Linear |
| 7 | HEY |
| 8 | WhatsApp |
| 9 | Spotify |
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
| `Option + Cmd + Space` | Workspace menu |
| `Option + arrows` | Focus window left/right/up/down |
| `Option + Shift + arrows` | Move window in workspace |
| `Option + Shift + 1-9` | Move window to workspace |
| `Option + Shift + S` | Move window to scratchpad (workspace 10) |
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
| `Option + Shift + C` | Open Google Calendar |
| `Option + Shift + E` | Open Gmail |
| `Option + Shift + G` | Open WhatsApp |
| `Option + Shift + M` | Open Spotify |
| `Option + Shift + O` | Open Obsidian |
| `Option + Shift + F` | Open Finder |
| `Option + Shift + /` | Open 1Password |
| `Option + Shift + A` | Open Claude |
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

##### Capture

| Hotkey | Action |
|---|---|
| `Option + Ctrl + C` | CleanShot all-in-one |

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
