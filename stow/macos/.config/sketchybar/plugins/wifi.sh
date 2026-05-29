#!/usr/bin/env bash

# Omarchy parity:
#   format (wifi)       → 5-bucket signal: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
#   format-ethernet     → 󰀂
#   format-disconnected → 󰤮
#
# Detection avoids `networksetup -getairportnetwork` because macOS 14+ silently
# returns empty unless the calling process has Location Services permission.
# Interface status + IP address is a permission-free, reliable substitute.

# Ethernet check — show ethernet icon if a wired interface is active
ETH_ACTIVE=$(networksetup -listallhardwareports 2>/dev/null | awk '
  /Hardware Port:/ { port=$0; sub(/Hardware Port: */,"",port); next }
  /Device:/        { dev=$2;
                     if (port !~ /Wi-Fi/ && port !~ /Bluetooth/) print dev
                   }' | while read -r dev; do
  ifconfig "$dev" 2>/dev/null | grep -q "status: active" && { echo 1; break; }
done)

if [ -n "$ETH_ACTIVE" ]; then
  sketchybar --set "$NAME" drawing=on icon="󰀂" label.drawing=off
  exit 0
fi

WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')

if [ -z "$WIFI_DEV" ]; then
  sketchybar --set "$NAME" drawing=on icon="󰤮" label.drawing=off
  exit 0
fi

WIFI_STATUS=$(ifconfig "$WIFI_DEV" 2>/dev/null | awk '/status:/ {print $2}')
WIFI_IP=$(ipconfig getifaddr "$WIFI_DEV" 2>/dev/null)

if [ "$WIFI_STATUS" != "active" ] || [ -z "$WIFI_IP" ]; then
  sketchybar --set "$NAME" drawing=on icon="󰤮" label.drawing=off
  exit 0
fi

RSSI=$(system_profiler SPAirPortDataType 2>/dev/null | awk -F': ' '/Signal \/ Noise/{split($2, a, " "); print a[1]; exit}')

if   [ -z "$RSSI" ];           then ICON="󰤨"
elif [ "$RSSI" -gt -50 ];      then ICON="󰤨"
elif [ "$RSSI" -gt -60 ];      then ICON="󰤥"
elif [ "$RSSI" -gt -70 ];      then ICON="󰤢"
elif [ "$RSSI" -gt -80 ];      then ICON="󰤟"
else                                ICON="󰤯"
fi

sketchybar --set "$NAME" drawing=on icon="$ICON" label.drawing=off
