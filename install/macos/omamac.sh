#!/usr/bin/env bash
set -euo pipefail

# Install Omamac if not already present (Omadots shell config is the most direct signal)
if [[ ! -f "$HOME/.config/shell/all" ]]; then
  curl -fsSL https://omamac.org/install | bash
else
    echo -e "\n==> Omamac already installed..."
fi

echo -e "\n=== Installing Sebastian's dotfiles ==="
