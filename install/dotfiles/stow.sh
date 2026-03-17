#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Stowing dotfiles..."

cd "$REPO_DIR/stow"
for config in git mise nvim ruby ssh zsh; do
  stow --target "$HOME" --restow --no-folding "$config"
done

echo "✓ Dotfiles stowed"
