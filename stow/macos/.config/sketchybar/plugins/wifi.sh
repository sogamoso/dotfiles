#!/usr/bin/env bash

WIFI=$(ipconfig getsummary en0 2>/dev/null | awk '/^  SSID :/{print $NF}')

if [ -z "$WIFI" ]; then
  sketchybar --set "$NAME" icon="󰤭" label.drawing=off
else
  sketchybar --set "$NAME" icon="󰤨" label.drawing=off
fi
