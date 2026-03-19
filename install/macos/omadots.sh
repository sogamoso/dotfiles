#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.config/shell/all" ]]; then
  log_heading "Installing Omadots..."
  curl -fsSL https://raw.githubusercontent.com/omacom-io/omadots/refs/heads/master/install.sh | zsh
else
  log_heading "Omadots already installed..."
  log_success "Skipping installation"
fi
