#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v stow >/dev/null 2>&1 || { echo "stow not found on PATH" >&2; exit 1; }
[[ -d "$REPO_DIR/stow" ]] || { echo "stow directory not found: $REPO_DIR/stow" >&2; exit 1; }

mkdir -p "$HOME/.ssh"

cd "$REPO_DIR/stow"

# Cross-platform packages
for pkg in */; do
  [[ "$pkg" == "macos/" ]] && continue
  stow --target "$HOME" --restow "$pkg"
done

# OS-specific packages
case "$(uname -s)" in
  Darwin) stow --target "$HOME" --restow macos ;;
esac
