#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Restarting SketchyBar..."
brew services restart sketchybar
echo "  ✓ Done"
