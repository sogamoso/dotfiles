#!/usr/bin/env bash
set -euo pipefail

APP="/Applications/Alacritty.app"

if [[ -d "$APP" ]]; then
  echo "Alacritty already installed, skipping."
  exit 0
fi

echo "Installing Alacritty from GitHub releases..."

# Get latest release DMG URL
DMG_URL=$(curl -fsSL https://api.github.com/repos/alacritty/alacritty/releases/latest \
  | grep "browser_download_url.*Alacritty-.*\.dmg" \
  | head -1 \
  | cut -d '"' -f 4)

if [[ -z "$DMG_URL" ]]; then
  echo "Could not find Alacritty DMG download URL" >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
DMG="$TMPDIR/Alacritty.dmg"

curl -fsSL -o "$DMG" "$DMG_URL"
MOUNT=$(hdiutil attach "$DMG" -nobrowse | tail -1 | awk '{print $NF}')
cp -R "$MOUNT/Alacritty.app" /Applications/
hdiutil detach "$MOUNT" -quiet
rm -rf "$TMPDIR"

echo "Alacritty installed."
