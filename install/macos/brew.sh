#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Installing personal Homebrew packages..."

# Install personal packages (Omamac handles core packages)
brew bundle --file "$REPO_DIR/Brewfile"

# Autoupdate once a week
if ! brew autoupdate status | grep -q "Autoupdate is installed and running"; then
  brew autoupdate start 604800 --ac-only --upgrade --cleanup --leaves-only --immediate --sudo
fi

# zsh-you-should-use (installed via Brewfile, link into plugin dir)
PLUGIN_DIR="$HOME/.config/zsh/plugins/zsh-you-should-use"
mkdir -p "$PLUGIN_DIR"
ln -sf "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" "$PLUGIN_DIR/you-should-use.plugin.zsh"
