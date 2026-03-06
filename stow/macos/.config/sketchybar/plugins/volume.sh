#!/bin/bash

# Maps to Omarchy's pulseaudio module icons

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME=$(osascript -e 'output volume of (get volume settings)')
fi

MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  ICON=""
elif [ "$VOLUME" -gt 66 ]; then
  ICON=""
elif [ "$VOLUME" -gt 33 ]; then
  ICON=""
else
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON"
