#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cache sudo credentials upfront — some casks (e.g. karabiner-elements) need them
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

bash "$DIR/omadots.sh"
bash "$DIR/brew.sh"
bash "$DIR/alacritty.sh"
bash "$DIR/dotfiles.sh"
bash "$DIR/tmux.sh"
bash "$DIR/karabiner.sh"
bash "$DIR/alt-tab.sh"
bash "$DIR/security.sh"
bash "$DIR/preferences.sh"
bash "$DIR/pwas.sh"
bash "$DIR/sketchybar.sh"
bash "$DIR/aerospace.sh"
