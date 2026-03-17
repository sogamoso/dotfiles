#!/usr/bin/env bash
set -euo pipefail

# Append personal supplement to .zshrc
OVERLAY='source $HOME/.config/zsh/supplement.zsh'
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >>"$HOME/.zshrc"
