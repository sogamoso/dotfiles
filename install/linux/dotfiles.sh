#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/stow-orphans.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Omarchy seeds these as real files from /etc/skel → let stow manage them instead.
# omarchy-reinstall-configs restores the originals if you ever want them back.
if [[ -f "$HOME/.config/hypr/bindings.lua" && ! -L "$HOME/.config/hypr/bindings.lua" ]]; then
  rm "$HOME/.config/hypr/bindings.lua"
fi

log_heading "Stowing Linux specific dotfiles..."

orphans=$(prune_stow_orphans "$REPO_DIR/stow")
(( orphans > 0 )) && log_item "Cleared $orphans link(s) left by a previous checkout location"

cd "$REPO_DIR/stow"
stow --target "$HOME" --restow --no-folding linux
log_success "Linux dotfiles stowed"
