#!/usr/bin/env bash

# Omarchy parity:
#   format (wifi)       → 5-bucket signal: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
#   format-ethernet     → 󰀂
#   format-disconnected → 󰤮

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

WIFI_SERVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')

if [ -z "$WIFI_SERVICE" ]; then
  sketchybar --set "$NAME" drawing=on icon="󰤮" label.drawing=off
  exit 0
fi

WIFI_POWER=$(networksetup -getairportpower "$WIFI_SERVICE" 2>/dev/null | awk '{print $NF}')
if [ "$WIFI_POWER" != "On" ]; then
  sketchybar --set "$NAME" drawing=on icon="󰤮" label.drawing=off
  exit 0
fi

WIFI_SSID=$(networksetup -getairportnetwork "$WIFI_SERVICE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
if [ -z "$WIFI_SSID" ] || [ "$WIFI_SSID" = "off" ] || echo "$WIFI_SSID" | grep -qi "not associated"; then
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
