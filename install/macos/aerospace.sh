#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  echo -e "\n==> Starting AeroSpace..."
  open -a AeroSpace
  echo "✓ AeroSpace launched — grant accessibility permissions when prompted"
fi

echo -e "\n==> Workspaces:"
echo "• 1  Ghostty / Zed"
echo "• 2  Chrome / Safari"
echo "• 3  Slack"
echo "• 4  Todoist / Gmail / Google Calendar"
echo "• 5  Notion / Linear"
echo "• 6  HEY"
echo "• 7  Spotify / YouTube"
echo "• 8  (free)"
echo "• 9  (free)"
echo "• 10 Scratchpad (Cmd+0)"
echo -e "\n! Grant accessibility permissions when prompted"
