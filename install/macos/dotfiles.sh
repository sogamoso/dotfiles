#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Take ownership of Ghostty config from Omamac (real file → symlink)
[[ -f "$HOME/.config/ghostty/config" && ! -L "$HOME/.config/ghostty/config" ]] && rm "$HOME/.config/ghostty/config"
[[ -f "$HOME/.config/ghostty/config.local" && ! -L "$HOME/.config/ghostty/config.local" ]] && rm "$HOME/.config/ghostty/config.local"

echo -e "\n==> Stowing macOS specific dotfiles..."
cd "$REPO_DIR/stow"
stow --target "$HOME" --restow macos
