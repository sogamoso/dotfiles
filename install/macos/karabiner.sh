#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Launching Karabiner-Elements..."
# Config is stowed to ~/.config/karabiner/karabiner.json (Cmd↔Ctrl swap)
open -a Karabiner-Elements

echo "✓ Karabiner launched"
echo -e "\n! Grant permissions when prompted:"
echo "• System Settings → Privacy & Security → Accessibility → Karabiner-Elements"
echo "• System Settings → Privacy & Security → Input Monitoring → Karabiner-Core-Service, Karabiner-EventViewer"
