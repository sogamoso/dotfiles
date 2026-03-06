#!/bin/bash

# Toggle between day+time and full date (maps to Omarchy clock format-alt)
CURRENT=$(sketchybar --query clock | grep -o '"label":"[^"]*"' | cut -d'"' -f4 2>/dev/null)

# If showing weekday format, switch to date format and vice versa
if echo "$CURRENT" | grep -q "^[A-Z]"; then
  sketchybar --set clock label="$(date '+%B %-d')"
  sleep 3
  sketchybar --set clock label="$(date '+%A %H:%M')"
else
  sketchybar --set clock label="$(date '+%A %H:%M')"
fi
