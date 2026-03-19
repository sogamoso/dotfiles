#!/usr/bin/env bash
set -euo pipefail

# Open the manual-steps guide only on first run — skip the interruption when re-running for updates
if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  touch "$HOME/.dotfiles-bootstrapped"
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  echo -e "\n==> Manual steps required. Opening guide..."
  open "$REPO_DIR/docs/macos-setup.md"
  echo "✓ Guide opened"
fi
