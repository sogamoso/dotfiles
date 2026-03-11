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
| `karabiner.sh` | Starts Karabiner-Elements only if not already running |
| `alt-tab.sh` | Configures AltTab window switcher |
| `preferences.sh` | macOS system defaults |
| `pwas.sh` | Installs Chrome PWAs (Gmail, Calendar, GitHub) |
| `sketchybar.sh` | Configures SketchyBar status bar |
| `aerospace.sh` | Starts AeroSpace only if not already running |
| `raycast.sh` | Opens Raycast for first-time setup |

#### Hotkeys

Follows [Omarchy](https://github.com/basecamp/omarchy)'s Hyprland keybinding model on macOS.

**External keyboards** — use an ANSI US layout keyboard (no Karabiner remapping needed).

**Built-in laptop keyboard** — Karabiner swaps Option↔Command so the physical key positions match an ANSI US layout.

#### Window management (Aerospace)

| Physical key | Action |
|---|---|
| `Ctrl + 1-9` | Switch to workspace 1–9 |
| `Ctrl + 0` | Workspace 10 (scratchpad) |
| `Ctrl + Shift + 1-9` | Move window to workspace |
| `Ctrl + arrows` | Focus window left/right/up/down |
| `Ctrl + Shift + arrows` | Move window within workspace |
| `Ctrl + W` | Close focused window |
| `Ctrl + F` | Fullscreen |
| `Ctrl + T` | Toggle floating/tiling |
| `Ctrl + Tab` | Next workspace |
| `Ctrl + Enter` | New Ghostty window |
| `Ctrl + Shift + Enter` | New Chrome window |
| `Ctrl + Shift + N` | New Zed window |
| `Cmd + Space` | Raycast launcher |

#### Window cycling

| Physical key | Action |
|---|---|
| `Alt + Tab` | Cycle windows on current workspace (AltTab) |
| `Alt + Shift + Tab` | Reverse cycle |

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

#### Manual setup guide

For the manual setup guide including Privacy & Security settings, Raycast, and Tokyo Night theming: [`docs/macos-manual-setup.md`](docs/macos-manual-setup.md).
