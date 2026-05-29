#!/usr/bin/env bash

# Two formats, toggled by clock_alt.sh.
#   normal: "Thursday 21:46"
#   alt:    "28 May W22 2026"

STATE=$(cat /tmp/sketchybar_clock_alt 2>/dev/null || echo "normal")

if [ "$STATE" = "alt" ]; then
  LABEL=$(date '+%d %B W%V %Y')
else
  LABEL=$(date '+%A %H:%M')
fi

sketchybar --set "$NAME" label="$LABEL"
