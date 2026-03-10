#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/xcode.sh"
bash "$DIR/omadots.sh"
bash "$DIR/security.sh"
bash "$DIR/onepassword.sh"
bash "$DIR/brew.sh"

# Ensure Homebrew-installed tools (stow, etc.) are on PATH for all subsequent subscripts
eval "$(/opt/homebrew/bin/brew shellenv)"
bash "$DIR/alacritty.sh"
bash "$DIR/dotfiles.sh"
bash "$DIR/tmux.sh"
bash "$DIR/karabiner.sh"
bash "$DIR/alt-tab.sh"
bash "$DIR/preferences.sh"
bash "$DIR/pwas.sh"
bash "$DIR/sketchybar.sh"
bash "$DIR/aerospace.sh"
bash "$DIR/raycast.sh"
