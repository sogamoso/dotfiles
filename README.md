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
  omadots/                 # supplement.zsh — personal additions to Omadots shell config
  ruby/                    # .gemrc, .irbrc, .default-gems
  ssh/                     # SSH client config + signing key
  zsh/                     # Shell aliases (git, gh, bundler, rails, npm)
```

### How it works

`bootstrap` runs two phases:

1. **OS setup** — dispatches by `uname -s`.
2. **Dotfiles** (`install/dotfiles.sh`) — cross-platform config symlinks via stow.

After both phases it checks Tailscale status and drops into a fresh zsh login shell.

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
| `pwas.sh` | Installs Chrome PWAs (Gmail, Calendar, GitHub) |
| `sketchybar.sh` | Configures SketchyBar status bar |
| `aerospace.sh` | Starts AeroSpace only if not already running |
| `raycast.sh` | Opens Raycast for first-time setup |

#### Hotkeys

Follows [Omarchy](https://github.com/basecamp/omarchy)'s Hyprland keybinding model on macOS.

Physical Option = SUPER (AeroSpace/window management). Physical Command = Alt (tmux).

#### Window management (Aerospace)

| Physical key | Action |
|---|---|
| `Option + 1-9` | Switch to workspace 1–9 |
| `Option + 0` | Workspace 10 (scratchpad) |
| `Option + Shift + 1-9` | Move window to workspace |
| `Option + arrows` | Focus window left/right/up/down |
| `Option + Shift + arrows` | Move window within workspace |
| `Option + W` | Close focused window |
| `Option + F` | Fullscreen |
| `Option + T` | Toggle floating/tiling |
| `Option + Tab` | Next workspace |
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
| `Option + Cmd + Enter` | Ghostty + tmux session |
| `Option + Shift + Cmd + B` | Chrome incognito |
| `Option + Shift + D` | LazyDocker in Ghostty |
| `Option + Ctrl + Tab` | Switch to former workspace |
| `Option + S` | Scratchpad (workspace 10) |
| `Option + Cmd + S` | Move window to scratchpad |
| `Option + Ctrl + C` | CleanShot all-in-one |
| `Option + Ctrl + L` | Lock screen |
| `Option + Ctrl + T` | btop in Ghostty |
| `Option + Ctrl + V` | Clipboard history (Raycast) |
| `Option + Ctrl + A` | Sound preferences |
| `Option + Ctrl + B` | Bluetooth preferences |
| `Option + Ctrl + W` | Wi-Fi preferences |
| `Option + Ctrl + X` | Monologue (dictation) |
| `Option + Ctrl + ,` | Toggle Do Not Disturb |
| `Option + ,` | Toggle Notification Center |
| `Option + Escape` | Apple menu (Raycast) |
| `Option + Cmd + Space` | Workspace menu |
| `Option + Space` | Raycast launcher |

#### Workspace layout

| Workspace | App |
|---|---|
| 1 | Ghostty |
| 2 | Chrome |
| 3 | Slack |
| 4 | Gmail |
| 5 | Todoist, Calendar, Meet |
| 6 | Notion, Linear, GitHub |
| 7 | HEY |
| 8 | WhatsApp |
| 9 | Spotify |
| 10 | (scratchpad) |

#### Terminal (Ghostty)

| Physical key | Action |
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
