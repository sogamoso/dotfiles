#!/usr/bin/env bash

BLUE=0xff7aa2f7
TEXT=0xffa9b1d6
MODE="${1:-mouse}"

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)

# Build rows and collect visible workspaces
VISIBLE=""
for i in {1..9}; do
  APPS=$(aerospace list-windows --workspace "$i" --format "%{app-name}" 2>/dev/null \
    | sort -u | paste -sd ', ' -)
  if [ -z "$APPS" ]; then
    sketchybar --set apple_menu.ws.$i drawing=off
  else
    [ ${#APPS} -gt 20 ] && APPS="${APPS:0:17}..."
    COLOR=$TEXT
    [ "$i" = "$FOCUSED" ] && COLOR=$BLUE
    sketchybar --set apple_menu.ws.$i \
      drawing=on \
      label="$i  $APPS" \
      label.color=$COLOR \
      background.drawing=off
    VISIBLE="$VISIBLE $i"
  fi
done
VISIBLE="${VISIBLE# }"

if [ "$MODE" = "keyboard" ]; then
  echo "$VISIBLE" > /tmp/sketchybar_menu_workspaces

  # Initial selection: focused workspace if visible, else first visible
  SELECTED="$FOCUSED"
  if ! echo "$VISIBLE" | grep -qw "$FOCUSED"; then
    SELECTED=$(echo "$VISIBLE" | awk '{print $1}')
  fi
  echo "$SELECTED" > /tmp/sketchybar_menu_selected
  touch /tmp/sketchybar_menu_keyboard

  sketchybar --set apple_menu.ws.$SELECTED background.drawing=on label.color=0xff1a1b26
  sketchybar --set apple_menu popup.drawing=on
else
  sketchybar --set apple_menu popup.drawing=toggle

  # Auto-close after 6s (covers same-app window clicks)
  TIMER_ID=$$
  echo $TIMER_ID > /tmp/sketchybar_menu_timer
  (sleep 6
    [ "$(cat /tmp/sketchybar_menu_timer 2>/dev/null)" = "$TIMER_ID" ] && \
      sketchybar --set apple_menu popup.drawing=off) &
fi
