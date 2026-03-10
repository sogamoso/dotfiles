#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Take ownership of configs from any real files → let stow manage them as symlinks
[[ -f "$HOME/.config/aerospace/aerospace.toml"  && ! -L "$HOME/.config/aerospace/aerospace.toml"  ]] && rm "$HOME/.config/aerospace/aerospace.toml"
[[ -f "$HOME/.config/alacritty/alacritty.toml"  && ! -L "$HOME/.config/alacritty/alacritty.toml"  ]] && rm "$HOME/.config/alacritty/alacritty.toml"
[[ -f "$HOME/.config/btop/btop.conf"            && ! -L "$HOME/.config/btop/btop.conf"            ]] && rm "$HOME/.config/btop/btop.conf"
[[ -f "$HOME/.config/ghostty/config"            && ! -L "$HOME/.config/ghostty/config"            ]] && rm "$HOME/.config/ghostty/config"
[[ -f "$HOME/.config/ghostty/config.local"      && ! -L "$HOME/.config/ghostty/config.local"      ]] && rm "$HOME/.config/ghostty/config.local"
[[ -f "$HOME/.config/karabiner/karabiner.json"  && ! -L "$HOME/.config/karabiner/karabiner.json"  ]] && rm "$HOME/.config/karabiner/karabiner.json"
[[ -f "$HOME/.config/tmux/tmux.local.conf"      && ! -L "$HOME/.config/tmux/tmux.local.conf"      ]] && rm "$HOME/.config/tmux/tmux.local.conf"
[[ -f "$HOME/.config/zed/settings.json"         && ! -L "$HOME/.config/zed/settings.json"         ]] && rm "$HOME/.config/zed/settings.json"

# Pre-create directories that apps write to, so stow links files individually
# instead of folding the whole directory into a symlink (which lets apps delete
# files through the symlink and corrupt the repo).
mkdir -p \
  "$HOME/.config/aerospace" \
  "$HOME/.config/alacritty" \
  "$HOME/.config/btop" \
  "$HOME/.config/ghostty" \
  "$HOME/.config/git" \
  "$HOME/.config/karabiner" \
  "$HOME/.config/raycast" \
  "$HOME/.config/sketchybar" \
  "$HOME/.config/tmux" \
  "$HOME/.config/zed" \
  "$HOME/.config/zsh"

echo -e "\n==> Stowing macOS specific dotfiles..."
cd "$REPO_DIR/stow"
stow --target "$HOME" --restow macos
