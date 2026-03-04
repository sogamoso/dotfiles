#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Removing apps superseded by AeroSpace..."
osascript -e 'tell application "Hammerspoon" to quit' 2>/dev/null || true
osascript -e 'tell application "Rectangle Pro" to quit' 2>/dev/null || true
brew uninstall --cask hammerspoon 2>/dev/null || true
brew uninstall --cask rectangle-pro 2>/dev/null || true
login_items=$(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || true)
remaining=()
[[ "$login_items" == *"Hammerspoon"* ]] && remaining+=("Hammerspoon")
[[ "$login_items" == *"Rectangle Pro"* ]] && remaining+=("Rectangle Pro")
if [[ ${#remaining[@]} -gt 0 ]]; then
  echo "  ⚠ Remove from Login Items manually: ${remaining[*]}"
fi
echo "  ✓ Done"

echo -e "\n==> Workspaces (managed automatically by AeroSpace):"
echo "  • 1 (Browsing):       Chrome, Safari"
echo "  • 2 (Programming):    Ghostty, Alacritty, Zed, Linear, GitHub, TablePlus"
echo "  • 3 (Communication):  Slack, Google Meet, WhatsApp, Discord"
echo "  • 4 (Scheduling):     Gmail, Google Calendar"
echo "  • 5 (Writing):        Typora, Obsidian, Notion, Notes"
echo "  • 6 (AI Tools):       ChatGPT, Claude, Codex"
echo "  • 7 (Entertainment):  Spotify, YouTube"
echo "  • 8 (Misc):           Everything else"
