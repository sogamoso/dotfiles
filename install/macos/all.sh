#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/omamac.sh"
bash "$DIR/brew.sh"
bash "$DIR/dotfiles.sh"
bash "$DIR/security.sh"
bash "$DIR/preferences.sh"
bash "$DIR/pwas.sh"
bash "$DIR/ghostty.sh"
bash "$DIR/hammerspoon.sh"
bash "$DIR/sketchybar.sh"
bash "$DIR/aerospace.sh"
