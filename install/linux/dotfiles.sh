#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/stow-orphans.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/take-ownership.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Omarchy seeds these as real files from /etc/skel.
# omarchy-reinstall-configs restores the originals if you ever want them back.
take_ownership "$HOME/.config/hypr/bindings.lua"

log_heading "Stowing Linux specific dotfiles..."

orphans=$(prune_stow_orphans "$REPO_DIR/stow")
(( orphans > 0 )) && log_item "Cleared $orphans link(s) left by a previous checkout location"

cd "$REPO_DIR/stow"
stow --target "$HOME" --restow --no-folding linux
log_success "Linux dotfiles stowed"
