#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v brew &>/dev/null; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

mkdir -p "$HOME/Library/LaunchAgents"  # not created by default on a fresh macOS install

echo -e "\n==> Installing Homebrew packages..."

# Install personal packages (Omamac handles core packages)
brew bundle --file "$REPO_DIR/Brewfile"

# Show packages not in the Brewfile — consider adding them or run: brew bundle cleanup --force
brew bundle cleanup --file "$REPO_DIR/Brewfile" || true

# Autoupdate once a week
if ! brew autoupdate status 2>/dev/null | grep -q "Autoupdate is installed and running"; then
  brew autoupdate delete 2>/dev/null || true
  brew autoupdate start 604800 --ac-only --upgrade --cleanup --leaves-only --immediate --sudo
fi

# zsh-you-should-use (installed via Brewfile, link into plugin dir)
PLUGIN_DIR="$HOME/.config/zsh/plugins/zsh-you-should-use"
mkdir -p "$PLUGIN_DIR"
ln -sf "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" "$PLUGIN_DIR/you-should-use.plugin.zsh"
