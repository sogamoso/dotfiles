#!/usr/bin/env bash

BLUE=0xff7aa2f7
TEXT=0xffa9b1d6

sketchybar --set apple_menu popup.drawing=toggle

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)

for i in {1..9}; do
  APPS=$(aerospace list-windows --workspace "$i" --format "%{app-name}" 2>/dev/null \
    | sort -u | paste -sd ', ' -)
  if [ -z "$APPS" ]; then
    sketchybar --set apple_menu.ws.$i drawing=off
  else
    [ ${#APPS} -gt 35 ] && APPS="${APPS:0:32}..."
    COLOR=$TEXT
    [ "$i" = "$FOCUSED" ] && COLOR=$BLUE
    sketchybar --set apple_menu.ws.$i \
      drawing=on \
      label="$i  $APPS" \
      label.color=$COLOR
  fi
done
