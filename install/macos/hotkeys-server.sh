#!/usr/bin/env bash
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/com.sogamoso.hotkeys-server.plist"
LABEL="com.sogamoso.hotkeys-server"

if launchctl list | grep -q "$LABEL"; then
  echo -e "\n==> Hotkeys server already running..."
  exit 0
fi

echo -e "\n==> Starting Hotkeys server..."
launchctl load "$PLIST"
