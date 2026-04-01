#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log_heading "Stowing dotfiles..."

cd "$REPO_DIR/stow"
for config in claude editorconfig git mise nvim ruby ssh zsh; do
  stow --target "$HOME" --restow --no-folding "$config"
done

log_success "Dotfiles stowed"
