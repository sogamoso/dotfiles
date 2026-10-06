#!/usr/bin/env bash

# Sticky toggle between Omarchy's two clock formats.
STATE_FILE="${TMPDIR:-/tmp}/dotfiles-sketchybar-clock"
STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

if [[ $STATE == "alt" ]]; then
  echo "normal" > "$STATE_FILE"
  sketchybar --set clock label="$(date '+%A %H:%M')"
else
  echo "alt" > "$STATE_FILE"
  sketchybar --set clock label="$(date '+%d %B W%V %Y')"
fi
