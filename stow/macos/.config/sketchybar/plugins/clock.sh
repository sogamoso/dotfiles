#!/usr/bin/env bash

# Omarchy's two clock formats; a right click toggles between them and the
# choice sticks. A left click opens the calendar, as Omarchy's does.
#   normal: "Thursday 21:46"
#   alt:    "28 May W22 2026"
# CLOCK_COMPACT=1 (laptop screen only, set by sketchybarrc) drops the weekday
# and the week number, which the space beside the notch can't fit:
#   normal: "21:46"
#   alt:    "28 May 2026"

STATE_FILE="${TMPDIR:-/tmp}/dotfiles-sketchybar-clock"
STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

if [[ ${SENDER:-} == "mouse.clicked" ]]; then
  if [[ ${BUTTON:-} != "right" ]]; then
    "$HOME/.config/aerospace/launch-or-focus.sh" "Google Calendar"
    exit 0
  fi
  [[ $STATE == "alt" ]] && STATE="normal" || STATE="alt"
  echo "$STATE" >"$STATE_FILE"
fi

if [[ ${CLOCK_COMPACT:-0} == 1 ]]; then
  [[ $STATE == "alt" ]] && LABEL=$(date '+%d %B %Y') || LABEL=$(date '+%H:%M')
elif [[ $STATE == "alt" ]]; then
  LABEL=$(date '+%d %B W%V %Y')
else
  LABEL=$(date '+%A %H:%M')
fi

sketchybar --set "$NAME" label="$LABEL"
