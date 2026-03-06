#!/usr/bin/env bash

VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

# Audio device doesn't expose volume (e.g. HDMI) — show icon, open Sound settings on click
if [ "$VOLUME" = "missing value" ] || [ -z "$VOLUME" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    icon="󰕾" \
    label.drawing=off \
    click_script="open 'x-apple.systempreferences:com.apple.preference.sound'"
  exit 0
fi

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  ICON="󰝟"
elif [ "$VOLUME" -gt 66 ]; then
  ICON="󰕾"
elif [ "$VOLUME" -gt 33 ]; then
  ICON="󰖀"
else
  ICON="󰕿"
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$ICON" \
  label.drawing=off \
  click_script="osascript -e 'set volume output muted not (output muted of (get volume settings))'"
