#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v brew &>/dev/null; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    log_heading "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

mkdir -p "$HOME/Library/LaunchAgents"  # not created by default on a fresh macOS install

log_heading "Installing Homebrew packages..."

source "$REPO_DIR/install/lib/brew-trust.sh"
brew_trust_taps "$REPO_DIR/Brewfile"

# Install personal packages (Omadots handles core packages)
brew bundle --file "$REPO_DIR/Brewfile"
brew cleanup || log_warn "brew cleanup had errors (often root-owned kegs from sudo services); continuing"

# Flag packages not in the Brewfile
STALE=$(brew bundle cleanup --file "$REPO_DIR/Brewfile" 2>&1 | grep -v "^Would uninstall\|^Run \`brew") || true
if [[ -n "$STALE" ]]; then
  log_success "Installed packages not in Brewfile:"
  echo "$STALE" | sed 's/^/  /'
  log_warn "Add them to the Brewfile to keep, or run: brew bundle cleanup --force"
else
  log_success "All installed packages are in the Brewfile"
fi

# herdr runs as a login-persistent background service (idempotent if already started)
brew services start herdr

# Autoupdate once a day
if ! brew autoupdate status 2>/dev/null | grep -q "Autoupdate is installed and running"; then
  brew autoupdate delete 2>/dev/null || true
  # --sudo needs pinentry-mac (installed via Brewfile above). Don't let a failure
  # here abort the run — all.sh aborts with it, skipping every later install script.
  brew autoupdate start 86400 --ac-only --upgrade --cleanup --leaves-only --immediate --sudo ||
    log_warn "brew autoupdate start failed; continuing without daily autoupdate"
fi

# zsh-you-should-use (installed via Brewfile, link into plugin dir)
PLUGIN_DIR="$HOME/.config/zsh/plugins/zsh-you-should-use"
mkdir -p "$PLUGIN_DIR"
ln -sf "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" "$PLUGIN_DIR/you-should-use.plugin.zsh"
