#!/usr/bin/env bash
# Show an indicator while a reminder is queued, with the count when there's
# more than one. Omarchy parity: its bar lights a glyph for a queued reminder.
# Reads the state reminder.sh keeps; a file whose process died isn't counted.

STATE_DIR="${TMPDIR:-/tmp}/dotfiles-reminders"

if [[ ${SENDER:-} == "mouse.clicked" ]]; then
  "$HOME/.config/dotfiles/reminder.sh" show
  exit 0
fi

COUNT=0
NOW=$(date +%s)
for f in "$STATE_DIR"/*.reminder; do
  [[ -e $f ]] || continue
  kill -0 "$(basename "$f" .reminder)" 2>/dev/null || continue
  IFS='|' read -r due _ <"$f"
  [[ $due =~ ^[0-9]+$ ]] && (( due > NOW )) && COUNT=$((COUNT + 1))
done

if (( COUNT == 0 )); then
  sketchybar --set "$NAME" drawing=off
elif (( COUNT == 1 )); then
  sketchybar --set "$NAME" drawing=on label.drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$COUNT" label.drawing=on
fi
