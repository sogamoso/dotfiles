## Dotfiles

Personal dotfiles layered on top of [Omamac](https://github.com/omacom-io/omamac). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

Omamac handles the base macOS setup (Omadots shell config, core packages, Ghostty, Hammerspoon, Rectangle Pro, Raycast, macOS defaults). This repo adds personal packages, aliases, security hardening, and configs.

### Installation

```
./bootstrap
```

Safe to run multiple times. Everything is idempotent.

### How it works

`bootstrap` runs two phases:

1. **macOS setup** (`install/macos/all.sh`) — OS-specific installs and settings
2. **Dotfiles** (`install/dotfiles.sh`) — cross-platform config symlinks via stow

After both phases it checks Tailscale status and drops into a fresh zsh login shell.

### Install scripts

```
install/
  dotfiles.sh              # Appends supplement source line to .zshrc, then stows all configs
  macos/
    all.sh                 # Orchestrator: runs the scripts below in order
    omamac.sh              # Installs Omamac if ~/.config/shell/all is missing
    brew.sh                # brew bundle from Brewfile, sets up autoupdate, links zsh plugins
    security.sh            # Enables SSH server, hardens sshd, enables macOS firewall
    preferences.sh         # Personal macOS defaults (menu bar spacing, control center items)
    pwas.sh                # Reminds to install Gmail/Calendar as Chrome PWAs if missing
```

### Stow directory

Each folder under `stow/` is a stow package. Running `stow --target $HOME --restow <package>` symlinks its contents into `$HOME`.

```
stow/
  git/                     # .gitconfig (cross-platform) + global .gitignore
  macos/                   # macOS-only configs (stowed only on Darwin)
    .config/git/config.macos           # 1Password SSH commit signing
    .config/omadots/supplement.macos.zsh  # 1Password SSH agent + op CLI completion
    .config/zsh/aliases/brew.zsh       # Homebrew aliases
  mise/                    # mise config (node + ruby via latest)
  omadots/                 # supplement.zsh — personal additions to Omadots shell config
  ruby/                    # .gemrc, .irbrc, .default-gems
  ssh/                     # SSH client config + signing key
  zsh/                     # Shell aliases (git, gh, bundler, rails, npm)
```

### Cross-platform design

The stow packages under `stow/` are cross-platform by default. macOS-specific configs live in `stow/macos/` and are only stowed on Darwin.

Two patterns keep configs portable:

- **Git**: `.gitconfig` uses `[include] path = ~/.config/git/config.macos`. Git silently ignores the include if the file doesn't exist (i.e. on Linux).
- **Shell**: `supplement.zsh` conditionally sources `supplement.macos.zsh` only if the file is readable. On Linux, the macOS stow package won't be installed so the file won't exist.

### Shell config chain

Omadots sets up `.zshrc` with its base shell config. This repo adds one line to `.zshrc`:

```
source $HOME/.config/omadots/supplement.zsh
```

That supplement file adds locale, editor vars, aliases, plugins, tmux auto-attach on SSH, and conditionally sources `supplement.macos.zsh` for 1Password SSH agent config.

### Other files

```
Brewfile                   # Personal Homebrew packages and casks
etc/ssh/sshd_config.d/     # sshd hardening (no passwords, no root login)
```
