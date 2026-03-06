#!/bin/bash

# Maps to Omarchy's network module:
#   format-icons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
#   format-ethernet: 󰀂
#   format-disconnected: 󰤮

WIFI_INFO=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null)

if [ -z "$WIFI_INFO" ] || echo "$WIFI_INFO" | grep -q "AirPort: Off"; then
  ICON="󰤮"
else
  RSSI=$(echo "$WIFI_INFO" | grep -w "agrCtlRSSI" | awk '{print $2}')

  if [ -z "$RSSI" ]; then
    # Wired / no WiFi signal → ethernet icon
    ICON="󰀂"
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
fi

sketchybar --set "$NAME" icon="$ICON"
