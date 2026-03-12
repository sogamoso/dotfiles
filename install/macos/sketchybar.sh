#!/usr/bin/env bash
set -euo pipefail

# Clean up compiled Swift helpers from old location (now build to ~/.cache/sketchybar)
for f in menu_bar_height has_external_display cpu_stats; do
  target="$HOME/.config/sketchybar/plugins/$f"
  [ -f "$target" ] && ! [ -L "$target" ] && rm "$target"
done

echo -e "\n==> Restarting SketchyBar..."
brew services restart sketchybar
echo "✓ Done"
