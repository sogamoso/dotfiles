#!/usr/bin/env bash
set -euo pipefail

OMADOTS_MARKER="$HOME/.config/shell/all"
OVERLAY='source $HOME/.config/omadots/supplement.zsh'

if [[ -f "$OMADOTS_MARKER" ]]; then
  echo "Omamac already installed, skipping."
else
  curl -fsSL https://raw.githubusercontent.com/omacom-io/omamac/master/install.sh | zsh
fi

# Append personal overlay to .zshrc
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >> "$HOME/.zshrc"
