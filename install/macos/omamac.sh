#!/usr/bin/env bash
set -euo pipefail

# Install Omamac if not already present (Omadots source line is the most direct signal)
if ! grep -qF 'source ~/.config/shell/all' "$HOME/.zshrc" 2>/dev/null; then
  curl -fsSL https://omamac.org/install | bash
fi
