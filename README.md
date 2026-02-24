## Dotfiles

My personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

I designed it to layer on top of an OS base setup — currently [Omamac](https://github.com/omacom-io/omamac) for macOS, with the structure ready to support other operating systems in the future.

### Installation

```
./bootstrap
```

Safe to run multiple times. Everything is idempotent.

#### How it works

`bootstrap` runs two phases:

1. **OS setup** — dispatches by `uname -s`. 
2. **Dotfiles** (`install/dotfiles.sh`) — cross-platform config symlinks via stow.

After both phases it checks Tailscale status and drops into a fresh zsh login shell.

### Stow directory

Each folder under `stow/` is a stow package. Running `stow --target $HOME --restow <package>` symlinks its contents into `$HOME`.

```
stow/
  git/                     # .gitconfig + global .gitignore
  macos/                   # macOS-only configs (stowed only on Darwin)
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
