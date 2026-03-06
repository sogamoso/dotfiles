#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Starting AeroSpace..."
if pgrep -x "AeroSpace" >/dev/null; then
  echo "✓ AeroSpace already running; skipping launch"
else
  open -a AeroSpace
  echo "✓ AeroSpace launched"
fi

echo -e "\n==> Workspaces:"
echo "• 1  Chrome"
echo "• 2  Ghostty / Alacritty"
echo "• 3  Slack"
echo "• 4  Gmail"
echo "• 5  Google Calendar"
echo "• 6  Notion"
echo "• 7  Spotify"
echo "• 8  YouTube"
echo "• 9  (free)"
echo "• 10 Scratchpad (Cmd+0)"
echo -e "\n! Grant accessibility permissions when prompted"
