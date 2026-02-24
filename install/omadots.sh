#!/usr/bin/env bash
set -euo pipefail

OMADOTS_MARKER="$HOME/.config/shell/all"
OVERLAY='source $HOME/.config/omadots/supplement.zsh'

if [[ -f "$OMADOTS_MARKER" ]]; then
  echo "Omadots already installed, skipping."
else
  curl -fsSL https://install.omacom.io/dots | bash
fi

# Append personal overlay to .zshrc
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >> "$HOME/.zshrc"

# Suppress "Last login" banner on new terminals
touch "$HOME/.hushlogin"
