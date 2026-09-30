#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/stow-orphans.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/take-ownership.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Guards for the cross-platform packages live in install/dotfiles/stow.sh,
# which is what stows them
take_ownership \
  "$HOME/.config/btop/btop.conf" \
  "$HOME/.config/ghostty/config" \
  "$HOME/.config/zed/settings.json" \
  "$HOME/.config/sketchybar/plugins/menu_bar_height" \
  "$HOME/.config/sketchybar/plugins/has_external_display" \
  "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate.plist" \
  "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-run.plist" \
  "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-watch.plist" \
  "$HOME/Library/LaunchAgents/com.sogamoso.workhours.sleep-if-idle.plist"

log_heading "Stowing macOS specific dotfiles..."

orphans=$(prune_stow_orphans "$REPO_DIR/stow")
(( orphans > 0 )) && log_item "Cleared $orphans link(s) left by a previous checkout location"

cd "$REPO_DIR/stow"
stow --target "$HOME" --restow --no-folding macos
log_success "macOS dotfiles stowed"
