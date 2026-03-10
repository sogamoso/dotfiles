#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "\n==> Stowing dotfiles..."

# Append personal supplement to .zshrc
OVERLAY='source $HOME/.config/zsh/supplement.zsh'
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >>"$HOME/.zshrc"

# Ensure .ssh exists before stowing SSH config
mkdir -p "$HOME/.ssh"

# Cross-platform dotfiles
cd "$REPO_DIR/stow"
for config in git mise nvim ruby ssh zsh; do
  stow --target "$HOME" --restow "$config"
done

echo "✓ Dotfiles stowed"

# Suppress "Last login" message
touch "$HOME/.hushlogin"

# Coderabbit. Writes directly to the .gitconfig so we need to strip it out
git -C "$REPO_DIR" config filter.strip-coderabbit.clean \
  "awk '/^\[coderabbit\]/{skip=1;next} /^\[/{skip=0} !skip{print}'"
