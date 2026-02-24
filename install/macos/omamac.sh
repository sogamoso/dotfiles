#!/usr/bin/env bash
set -euo pipefail

# Install Omamac if not already present (Rectangle Pro is a reliable Omamac signal)
if ! brew list --cask rectangle-pro &>/dev/null 2>&1; then
  curl -fsSL https://omamac.org/install | bash
fi
