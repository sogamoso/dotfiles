#!/usr/bin/env bash

BT_STATUS=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)

if [ "$BT_STATUS" = "0" ]; then
  ICON="󰂲"
else
  CONNECTED=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -c "Connected: Yes")
  if [ "$CONNECTED" -gt 0 ]; then
    ICON="󰂱"
  else
    ICON="󰂯"
  fi
fi

sketchybar --set "$NAME" icon="$ICON" label.drawing=off
