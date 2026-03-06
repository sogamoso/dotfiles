#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Configuring AltTab..."

# Show only windows on the current Aerospace workspace (matches Hyprland per-workspace cycling)
defaults write com.lwouis.alt-tab-macos spacesDisplayMode -int 1

echo "✓ AltTab configured"
echo -e "\n! Grant accessibility permissions when prompted, then set hotkey to Option+Tab in AltTab preferences"
