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
echo "• 1  Ghostty / Safari"
echo "• 2  Slack"
echo "• 3  Todoist / Gmail / Google Calendar"
echo "• 4  Notion / Linear"
echo "• 5  HEY"
echo "• 6  Spotify / YouTube"
echo "• 7  (free)"
echo "• 8  (free)"
echo "• 9  (free)"
echo "• 10 Scratchpad (Cmd+0)"
echo -e "\n! Grant accessibility permissions when prompted"
