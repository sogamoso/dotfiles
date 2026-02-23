#!/usr/bin/env bash
set -euo pipefail

OMADOTS_MARKER="$HOME/.config/shell/all"
OVERLAY='source $HOME/.config/omadots/supplement.zsh'

if [[ -f "$OMADOTS_MARKER" ]]; then
  echo "Omamac already installed, skipping."
else
  # Unstow first — Omamac's cp -Rf chokes on stow symlinks in ~/.config
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if command -v stow >/dev/null 2>&1 && [[ -d "$REPO_DIR/stow" ]]; then
    (cd "$REPO_DIR/stow" && stow --target "$HOME" --delete */ 2>/dev/null || true)
  fi

  curl -fsSL https://raw.githubusercontent.com/omacom-io/omamac/master/install.sh | zsh
fi

# Append personal overlay to .zshrc
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >> "$HOME/.zshrc"
