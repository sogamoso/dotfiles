#!/bin/bash

# Click the clock to flash the ISO week number, then revert to time.

STATE=$(cat /tmp/sketchybar_clock_alt 2>/dev/null || echo "normal")

if [ "$STATE" = "normal" ]; then
  echo "week" > /tmp/sketchybar_clock_alt
  sketchybar --set clock label="Week $(date '+%-V')"
  sleep 3
  sketchybar --set clock label="$(date '+%H:%M')"
  echo "normal" > /tmp/sketchybar_clock_alt
else
  sketchybar --set clock label="$(date '+%H:%M')"
  echo "normal" > /tmp/sketchybar_clock_alt
fi
