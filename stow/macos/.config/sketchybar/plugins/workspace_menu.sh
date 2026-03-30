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

# Single query for all windows, parsed into per-workspace summaries
WS_SUMMARY=$(aerospace list-windows --all --format "%{workspace} %{app-name}" 2>/dev/null | \
  sort | awk '
    {
      ws = $1; app = substr($0, length(ws) + 2)
      if (!(ws SUBSEP app in seen)) {
        seen[ws SUBSEP app] = 1; count[ws]++
        if (count[ws] <= 3) label[ws] = (label[ws] ? label[ws] ", " app : app)
      }
    }
    END {
      for (ws in count) {
        extra = count[ws] > 3 ? " +" (count[ws] - 3) : ""
        print ws "|" label[ws] extra
      }
    }
  ' | sort)

# Build a lookup of workspace → app summary
declare -A WS_APPS
while IFS='|' read -r ws apps; do
  [ -z "$ws" ] && continue
  WS_APPS[$ws]="$apps"
done <<< "$WS_SUMMARY"

# Show all workspaces (1-9), with app labels for occupied ones
ARGS=()
VISIBLE=""
for ws in $(seq 1 9); do
  COLOR=$TEXT
  [ "$ws" = "$FOCUSED" ] && COLOR=$BLUE
  if [ -n "${WS_APPS[$ws]}" ]; then
    ARGS+=(--set "apple_menu.ws.$ws" drawing=on "label=$ws  ${WS_APPS[$ws]}" "label.color=$COLOR" background.drawing=off)
  else
    ARGS+=(--set "apple_menu.ws.$ws" drawing=on "label=$ws" "label.color=$COLOR" background.drawing=off)
  fi
  VISIBLE="$VISIBLE $ws"
done
VISIBLE="${VISIBLE# }"
sketchybar "${ARGS[@]}"

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
