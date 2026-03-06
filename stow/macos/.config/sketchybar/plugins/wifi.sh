#!/usr/bin/env bash

RSSI=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Signal \/ Noise/{print $4}')

if [ -z "$RSSI" ]; then
  ICON="󰤭"  # disconnected
elif [ "$RSSI" -gt -50 ]; then
  ICON="󰤨"  # excellent
elif [ "$RSSI" -gt -60 ]; then
  ICON="󰤥"  # good
elif [ "$RSSI" -gt -70 ]; then
  ICON="󰤢"  # fair
elif [ "$RSSI" -gt -80 ]; then
  ICON="󰤟"  # weak
else
  ICON="󰤯"  # very weak
fi

sketchybar --set "$NAME" icon="$ICON" label.drawing=off
