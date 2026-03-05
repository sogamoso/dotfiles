#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Launching Karabiner-Elements..."
# Config is stowed to ~/.config/karabiner/karabiner.json (Cmd↔Ctrl swap)
open -a Karabiner-Elements

echo "  ✓ Karabiner launched — grant permissions when prompted:"
echo "    System Settings → Privacy & Security → Accessibility → Karabiner-Elements"
echo "    System Settings → Privacy & Security → Input Monitoring → karabiner_grabber, karabiner_observer"
