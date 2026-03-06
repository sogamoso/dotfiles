#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "$HOME/.config/shell/all" ]]; then
  echo -e "\n==> Installing Omadots..."
  curl -fsSL https://raw.githubusercontent.com/omacom-io/omadots/refs/heads/master/install.sh | zsh
else
  echo -e "\n==> Omadots already installed..."
fi
