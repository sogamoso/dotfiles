#!/usr/bin/env bash

BLUE=0xff7aa2f7
TEXT=0xffa9b1d6
MODE="${1:-mouse}"

# Mouse toggle: close if already open
if [ "$MODE" = "mouse" ] && [ -f /tmp/sketchybar_popup_open ]; then
  rm -f /tmp/sketchybar_popup_open
  sketchybar --set apple_menu popup.drawing=off
  aerospace mode main 2>/dev/null
  exit 0
fi

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)

# Build rows and collect visible workspaces
VISIBLE=""
for i in {1..9}; do
  APPS_ALL=$(aerospace list-windows --workspace "$i" --format "%{app-name}" 2>/dev/null | sort -u)
  if [ -z "$APPS_ALL" ]; then
    sketchybar --set apple_menu.ws.$i drawing=off
  else
    TOTAL=$(echo "$APPS_ALL" | wc -l | tr -d ' ')
    APPS=$(echo "$APPS_ALL" | head -2 | paste -sd ', ' -)
    [ "$TOTAL" -gt 2 ] && APPS="$APPS +$(( TOTAL - 2 ))"
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

auto_close() {
  local id="$1" delay="$2"
  (sleep "$delay"
    [ "$(cat /tmp/sketchybar_menu_timer 2>/dev/null)" = "$id" ] && {
      rm -f /tmp/sketchybar_popup_open /tmp/sketchybar_menu_keyboard
      sketchybar --set apple_menu popup.drawing=off
      aerospace mode main 2>/dev/null
    }) &
}

TIMER_ID=$$
echo $TIMER_ID > /tmp/sketchybar_menu_timer

if [ "$MODE" = "keyboard" ]; then
  echo "$VISIBLE" > /tmp/sketchybar_menu_workspaces

  SELECTED="$FOCUSED"
  if ! echo "$VISIBLE" | grep -qw "$FOCUSED"; then
    SELECTED=$(echo "$VISIBLE" | awk '{print $1}')
  fi
  echo "$SELECTED" > /tmp/sketchybar_menu_selected
  touch /tmp/sketchybar_menu_keyboard

  sketchybar --set apple_menu.ws.$SELECTED background.drawing=on label.color=0xff1a1b26
  sketchybar --set apple_menu popup.drawing=on
  auto_close "$TIMER_ID" 4
else
  touch /tmp/sketchybar_popup_open
  sketchybar --set apple_menu popup.drawing=on
  aerospace mode workspace_menu 2>/dev/null
  auto_close "$TIMER_ID" 2
fi
