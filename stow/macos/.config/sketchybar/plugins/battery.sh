#!/bin/bash

# Maps to Omarchy battery module with matching icon tiers and warning states

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"
WATTS="$(pmset -g batt | grep -Eo "\d+\.\d+ W" | head -1)"

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# Icon tiers matching Omarchy's format-icons
if [ -n "$CHARGING" ]; then
  case "$PERCENTAGE" in
    100)        ICON="󰂅" ;;
    9[0-9])     ICON="󰂋" ;;
    8[0-9])     ICON="󰂊" ;;
    7[0-9])     ICON="󰢞" ;;
    6[0-9])     ICON="󰂉" ;;
    5[0-9])     ICON="󰢝" ;;
    4[0-9])     ICON="󰂈" ;;
    3[0-9])     ICON="󰂇" ;;
    2[0-9])     ICON="󰂆" ;;
    *)          ICON="󰢜" ;;
  esac
else
  case "$PERCENTAGE" in
    100)        ICON="󰁹" ;;
    9[0-9])     ICON="󰂂" ;;
    8[0-9])     ICON="󰂁" ;;
    7[0-9])     ICON="󰂀" ;;
    6[0-9])     ICON="󰁿" ;;
    5[0-9])     ICON="󰁾" ;;
    4[0-9])     ICON="󰁽" ;;
    3[0-9])     ICON="󰁼" ;;
    2[0-9])     ICON="󰁻" ;;
    *)          ICON="󰁺" ;;
  esac
fi

# Color warnings matching Omarchy's states (warning: 20, critical: 10)
COLOR="0xffa9b1d6"  # default foreground
if [ -z "$CHARGING" ]; then
  if [ "$PERCENTAGE" -le 10 ]; then
    COLOR="0xfff7768e"  # critical — red
  elif [ "$PERCENTAGE" -le 20 ]; then
    COLOR="0xffe0af68"  # warning — yellow
  fi
fi

# Omarchy shows icon only when not on AC; shows percentage on hover
# Here we show icon always, label only when discharging below 20%
LABEL=""
if [ -z "$CHARGING" ] && [ "$PERCENTAGE" -le 20 ]; then
  LABEL="${PERCENTAGE}%"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$COLOR" \
  label="$LABEL" \
  label.color="$COLOR"
