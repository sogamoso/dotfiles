#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Take ownership of configs from any real files → let stow manage them as symlinks
[[ -f "$HOME/.config/alacritty/alacritty.toml"  && ! -L "$HOME/.config/alacritty/alacritty.toml"  ]] && rm "$HOME/.config/alacritty/alacritty.toml"
[[ -f "$HOME/.config/btop/btop.conf"            && ! -L "$HOME/.config/btop/btop.conf"            ]] && rm "$HOME/.config/btop/btop.conf"
[[ -f "$HOME/.config/ghostty/config"            && ! -L "$HOME/.config/ghostty/config"            ]] && rm "$HOME/.config/ghostty/config"
[[ -f "$HOME/.config/zed/settings.json"         && ! -L "$HOME/.config/zed/settings.json"         ]] && rm "$HOME/.config/zed/settings.json"
for f in menu_bar_height has_external_display cpu_stats; do
  [[ -f "$HOME/.config/sketchybar/plugins/$f" && ! -L "$HOME/.config/sketchybar/plugins/$f" ]] && rm "$HOME/.config/sketchybar/plugins/$f"
done
[[ -f "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate.plist"       && ! -L "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate.plist"       ]] && rm "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate.plist"
[[ -f "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-watch.plist" && ! -L "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-watch.plist" ]] && rm "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-watch.plist"
[[ -f "$HOME/Library/LaunchAgents/com.sogamoso.workhours.sleep-if-idle.plist"    && ! -L "$HOME/Library/LaunchAgents/com.sogamoso.workhours.sleep-if-idle.plist"    ]] && rm "$HOME/Library/LaunchAgents/com.sogamoso.workhours.sleep-if-idle.plist"

echo -e "\n==> Stowing macOS specific dotfiles..."
cd "$REPO_DIR/stow"
stow --target "$HOME" --restow --no-folding macos
echo "✓ macOS dotfiles stowed"
