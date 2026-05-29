#!/bin/bash

# Sticky toggle between Omarchy's two clock formats.
STATE=$(cat /tmp/sketchybar_clock_alt 2>/dev/null || echo "normal")

if [ "$STATE" = "alt" ]; then
  echo "normal" > /tmp/sketchybar_clock_alt
  sketchybar --set clock label="$(date '+%A %H:%M')"
else
  echo "alt" > /tmp/sketchybar_clock_alt
  sketchybar --set clock label="$(date '+%d %B W%V %Y')"
fi
