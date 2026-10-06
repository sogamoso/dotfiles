#!/usr/bin/env bash

# Omarchy's two clock formats; a click toggles between them and the choice sticks.
#   normal: "Thursday 21:46"
#   alt:    "28 May W22 2026"

STATE_FILE="${TMPDIR:-/tmp}/dotfiles-sketchybar-clock"
STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

if [[ ${SENDER:-} == "mouse.clicked" ]]; then
  [[ $STATE == "alt" ]] && STATE="normal" || STATE="alt"
  echo "$STATE" >"$STATE_FILE"
fi

if [[ $STATE == "alt" ]]; then
  LABEL=$(date '+%d %B W%V %Y')
else
  LABEL=$(date '+%A %H:%M')
fi

sketchybar --set "$NAME" label="$LABEL"
