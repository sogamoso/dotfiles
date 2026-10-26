#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Omarchy's Neovim is LazyVim, which starts from its starter config. It runs
# before stow links the repo's plugins into ~/.config/nvim, and once the starter
# is in place it's left alone: LazyVim updates itself through lazy.nvim.
NVIM_CONFIG="$HOME/.config/nvim"

if [[ -f $NVIM_CONFIG/init.lua ]]; then
  log_heading "LazyVim already installed..."
  log_success "Skipping installation"
  exit 0
fi

log_heading "Installing LazyVim..."
starter=$(mktemp -d)
trap 'rm -rf "$starter"' EXIT
git clone --quiet --depth 1 https://github.com/LazyVim/starter "$starter"
rm -rf "$starter/.git"
mkdir -p "$NVIM_CONFIG"
cp -R "$starter/." "$NVIM_CONFIG/"

# LazyVim rewrites this file itself, so it's seeded here rather than stowed.
# Omadots enabled neo-tree this way, and the nvim package configures it.
if [[ ! -f $NVIM_CONFIG/lazyvim.json ]]; then
  cat >"$NVIM_CONFIG/lazyvim.json" <<'EOF'
{
  "extras": [
    "lazyvim.plugins.extras.editor.neo-tree"
  ],
  "install_version": 8,
  "version": 8
}
EOF
fi
log_success "LazyVim installed"
