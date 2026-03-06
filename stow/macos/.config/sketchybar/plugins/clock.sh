#!/usr/bin/env bash

# Auto-reload bar if display count changed and clock position is wrong
DISPLAY_COUNT=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c "Resolution:")
CLOCK_POS=$(sketchybar --query "$NAME" 2>/dev/null | grep -o '"position":"[^"]*"' | cut -d'"' -f4)

if { [ "$DISPLAY_COUNT" -le 1 ] && [ "$CLOCK_POS" = "center" ]; } || \
   { [ "$DISPLAY_COUNT" -gt 1 ] && [ "$CLOCK_POS" = "right" ]; }; then
  sketchybar --reload
  exit 0
fi

sketchybar --set "$NAME" label="$(date '+%A %H:%M')"
