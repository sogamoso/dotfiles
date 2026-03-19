#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/xcode.sh"
bash "$DIR/omadots.sh"
bash "$DIR/security.sh"
bash "$DIR/brew.sh"

# Ensure Homebrew-installed tools (i.e. stow) are on PATH for subsequent scripts
eval "$(/opt/homebrew/bin/brew shellenv)"

bash "$DIR/onepassword.sh"
bash "$DIR/alacritty.sh"
bash "$DIR/dotfiles.sh"
bash "$DIR/tmux.sh"
bash "$DIR/preferences.sh"
bash "$DIR/pwas.sh"
bash "$DIR/sketchybar.sh"
bash "$DIR/aerospace.sh"
bash "$DIR/raycast.sh"

# Open the manual-steps guide only on first run — skip the interruption when re-running for updates
if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  touch "$HOME/.dotfiles-bootstrapped"
  REPO_DIR="$(cd "$DIR/../.." && pwd)"
  echo -e "\n==> Manual steps required. Opening guide..."
  open "$REPO_DIR/docs/macos-setup.md"
  echo "✓ Guide opened"
fi
