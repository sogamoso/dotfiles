#!/usr/bin/env bash
# Weather indicator from wttr.in. Hides on network/API failure.
# wttr.in geolocates by IP, so units (C vs F) follow your IP's locale.

DATA=$(curl -fsS --max-time 5 'wttr.in/?format=%t,%x' 2>/dev/null) || {
  sketchybar --set "$NAME" drawing=off
  exit 0
}

TEMP=$(echo "$DATA" | cut -d',' -f1 | tr -d '+CF')
CODE=$(echo "$DATA" | cut -d',' -f2)

[ -z "$TEMP" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

# Map WWO condition codes to Nerd Font weather glyphs.
case "$CODE" in
  113)         ICON="󰖙" ;;  # Sunny / Clear
  116)         ICON="󰖕" ;;  # Partly cloudy
  119|122)     ICON="󰖐" ;;  # Cloudy / Overcast
  143|248|260) ICON="󰖑" ;;  # Fog / Mist
  200)         ICON="󰖓" ;;  # Thunder
  179|182|185|227|230|323|326|329|332|335|338|350|362|365|368|371|374|377)
               ICON="󰖘" ;;  # Snow
  *)           ICON="󰖗" ;;  # Default: rain / drizzle
esac

sketchybar --set "$NAME" drawing=on icon="$ICON" label="$TEMP"
