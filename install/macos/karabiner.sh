#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Launching Karabiner-Elements..."
# Config is stowed to ~/.config/karabiner/karabiner.json (Cmd↔Ctrl swap)
if pgrep -f "Karabiner-Elements" >/dev/null; then
  echo "✓ Karabiner-Elements already running; skipping launch"
else
  open -a Karabiner-Elements
  echo "✓ Karabiner launched"
  echo -e "\n! Grant permissions when prompted:"
  echo "• System Settings → Privacy & Security → Accessibility → Karabiner-Elements"
  echo "• System Settings → Privacy & Security → Input Monitoring → Karabiner-Core-Service, Karabiner-EventViewer"
fi
