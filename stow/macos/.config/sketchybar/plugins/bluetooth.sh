#!/usr/bin/env bash

# Omarchy parity:
#   format-connected     → 󰂱 (visible)
#   format-off/disabled  → 󰂲 (visible)
#   format               → "" (hidden when on but no device connected)
#   format-no-controller → "" (hidden on machines without bluetooth)

if ! command -v blueutil &>/dev/null; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

BT_STATUS=$(blueutil -p 2>/dev/null)

# No controller / blueutil can't read state
if [ -z "$BT_STATUS" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$BT_STATUS" = "0" ]; then
  sketchybar --set "$NAME" drawing=on icon="󰂲" label.drawing=off
  exit 0
fi

CONNECTED=$(blueutil --connected | wc -l | tr -d ' ')
if [ "$CONNECTED" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on icon="󰂱" label.drawing=off
else
  sketchybar --set "$NAME" drawing=off
fi
