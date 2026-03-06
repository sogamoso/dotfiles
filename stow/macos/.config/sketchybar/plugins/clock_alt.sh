#!/bin/bash

STATE=$(cat /tmp/sketchybar_clock_alt 2>/dev/null || echo "time")

if [ "$STATE" = "time" ]; then
  echo "date" > /tmp/sketchybar_clock_alt
  sketchybar --set clock label="$(date '+%B %-d')"
  sleep 3
  sketchybar --set clock label="$(date '+%A %H:%M')"
  echo "time" > /tmp/sketchybar_clock_alt
else
  sketchybar --set clock label="$(date '+%A %H:%M')"
  echo "time" > /tmp/sketchybar_clock_alt
fi
