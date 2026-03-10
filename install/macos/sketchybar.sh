#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Restarting SketchyBar..."
mkdir -p "$HOME/Library/LaunchAgents"
brew services restart sketchybar
echo "✓ Done"
