#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" # Make brew available in THIS shell
fi

command -v brew >/dev/null 2>&1 || { echo "brew not found on PATH after install" >&2; exit 1; }

brew update
brew bundle --file "$REPO_DIR/Brewfile"
brew cleanup
