#!/usr/bin/env bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

[ -z "$PERCENTAGE" ] && exit 0

if [ -n "$CHARGING" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$PERCENTAGE" -gt 80 ]; then
  ICON="󰁹"
elif [ "$PERCENTAGE" -gt 60 ]; then
  ICON="󰂀"
elif [ "$PERCENTAGE" -gt 40 ]; then
  ICON="󰁾"
elif [ "$PERCENTAGE" -gt 20 ]; then
  ICON="󰁼"
else
  ICON="󰁺"
fi

sketchybar --set "$NAME" drawing=on icon="$ICON" label="${PERCENTAGE}%"
