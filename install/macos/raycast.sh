#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Launching Raycast..."
if pgrep -f "Raycast" >/dev/null; then
  echo "✓ Raycast already running; skipping launch"
else
  open -a Raycast
  echo "✓ Raycast launched"
  echo -e "\n! Raycast setup:"
  echo "• Complete the setup wizard"
  echo "• Set hotkey to Ctrl+Space (maps to physical Cmd+Space after Karabiner swap)"
  echo "• Import snippets: Settings → Import → ~/.config/raycast/snippets.json"
fi
