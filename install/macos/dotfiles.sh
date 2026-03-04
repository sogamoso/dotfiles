#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Stowing macOS specific dotfiles..."
cd "$REPO_DIR/stow"
stow --target "$HOME" --restow macos
