#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/xcode.sh"
bash "$DIR/lazyvim.sh"
bash "$DIR/security.sh"
bash "$DIR/brew.sh"

# Ensure Homebrew-installed tools (i.e. stow) are on PATH for subsequent scripts
eval "$(/opt/homebrew/bin/brew shellenv)"

bash "$DIR/onepassword.sh"
bash "$DIR/../dotfiles/stow.sh"
# The stowed helper, shared with dotfiles brew and the daily check that
# preferences.sh loads; allowing first keeps that check from firing on day one.
# --install adds the root daemon that re-allows after background upgrades.
bash "$HOME/.config/dotfiles/firewall.sh"
bash "$HOME/.config/dotfiles/firewall.sh" --install
bash "$DIR/preferences.sh"
bash "$DIR/pwas.sh"
bash "$DIR/mailto.sh"
bash "$DIR/sketchybar.sh"
bash "$DIR/tailscale.sh"
bash "$DIR/aerospace.sh"
bash "$DIR/vicinae.sh"
bash "$DIR/neovim.sh"
bash "$DIR/apps.sh"
bash "$DIR/manual_steps.sh"
