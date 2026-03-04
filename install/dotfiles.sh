#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "\n==> Stowing dotfiles..."

# Append personal supplement to .zshrc
OVERLAY='source $HOME/.config/zsh/supplement.zsh'
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >> "$HOME/.zshrc"

command -v stow >/dev/null 2>&1 || { echo "stow not found on PATH" >&2; exit 1; }
[[ -d "$REPO_DIR/stow" ]] || { echo "stow directory not found: $REPO_DIR/stow" >&2; exit 1; }

mkdir -p "$HOME/.ssh"

cd "$REPO_DIR/stow"

# Cross-platform configs
for config in */; do
  [[ "$config" == "macos/" ]] && continue
  stow --target "$HOME" --restow "$config"
done

# Strip machine-specific sections from .gitconfig when staging
git -C "$REPO_DIR" config filter.strip-coderabbit.clean \
  "awk '/^\[coderabbit\]/{skip=1;next} /^\[/{skip=0} !skip{print}'"
