#!/usr/bin/env bash
# Show an indicator only while the microphone is muted.
# Omarchy parity: Quattro's bar carries a microphone state indicator.
# Quiet by default, like dotfiles_update — nothing on the bar when unmuted.
set -u

LEVEL=$(osascript -e 'input volume of (get volume settings)' 2>/dev/null)

# osascript returns "missing value" when there is no input device at all
case "$LEVEL" in
  '' | *[!0-9]*) sketchybar --set "$NAME" drawing=off; exit 0 ;;
esac

if [ "$LEVEL" -eq 0 ]; then
  sketchybar --set "$NAME" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
