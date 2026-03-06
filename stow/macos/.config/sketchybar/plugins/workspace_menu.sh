#!/usr/bin/env bash

BLUE=0xff7aa2f7
TEXT=0xffa9b1d6

sketchybar --set apple_menu popup.drawing=toggle

# Auto-close after 6s (covers clicking back on the same app)
TIMER_ID=$$
echo $TIMER_ID > /tmp/sketchybar_menu_timer
(sleep 6
  [ "$(cat /tmp/sketchybar_menu_timer 2>/dev/null)" = "$TIMER_ID" ] && \
    sketchybar --set apple_menu popup.drawing=off) &

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
