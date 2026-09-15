#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Open the manual-steps guide only on first run — skip the interruption when re-running for updates
if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  touch "$HOME/.dotfiles-bootstrapped"
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  log_heading "Manual steps required. Opening guide..."
  if open "$REPO_DIR/docs/macos-manual-setup.md"; then
    log_success "Guide opened"
  else
    log_warn "Could not open the guide — read docs/macos-manual-setup.md"
  fi
fi
