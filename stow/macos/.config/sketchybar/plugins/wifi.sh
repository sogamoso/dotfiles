#!/usr/bin/env bash

WIFI=$(networksetup -getairportnetwork en0 2>/dev/null | cut -d: -f2 | xargs)

if [ -z "$WIFI" ] || [ "$WIFI" = "You are not associated with an AirPort network." ]; then
  sketchybar --set "$NAME" icon="󰤭" label="Off"
else
  sketchybar --set "$NAME" icon="󰤨" label="$WIFI"
fi
