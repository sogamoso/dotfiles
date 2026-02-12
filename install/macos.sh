#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" # Make brew available in THIS shell
fi

command -v brew >/dev/null 2>&1 || { echo "brew not found on PATH after install" >&2; exit 1; }

# Install new casks and formulae
brew bundle --file "$REPO_DIR/Brewfile"

# Autoupdate now and once a week
brew autoupdate delete >/dev/null 2>&1 || true
brew autoupdate start 604800 --ac-only --upgrade --cleanup --leaves-only --immediate --sudo

# zsh-you-should-use
PLUGIN_DIR="$HOME/.config/zsh/plugins/zsh-you-should-use"
mkdir -p "$PLUGIN_DIR"
ln -sf "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" "$PLUGIN_DIR/you-should-use.plugin.zsh"
