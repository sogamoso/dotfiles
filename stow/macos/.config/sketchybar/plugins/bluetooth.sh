#!/usr/bin/env bash

BT_ON=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -c "State: On")

if [ "$BT_ON" -eq 0 ]; then
  sketchybar --set "$NAME" icon="󰂲" label.drawing=off
else
  sketchybar --set "$NAME" icon="󰂯" label.drawing=off
fi
