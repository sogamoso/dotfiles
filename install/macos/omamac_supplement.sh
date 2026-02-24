#!/usr/bin/env bash
set -euo pipefail

# Append personal overlay to .zshrc (Omadots is already installed by Omamac)
OVERLAY='source $HOME/.config/omadots/supplement.zsh'
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >> "$HOME/.zshrc"

# Suppress "Last login" banner on new terminals
touch "$HOME/.hushlogin"
