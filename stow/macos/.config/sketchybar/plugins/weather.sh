#!/usr/bin/env bash
# Current conditions from wttr.in, next to the clock as in Omarchy's bar.
# Omarchy parity: click opens the forecast, right click shows the full weather
# as a notification, middle click refreshes. A failed fetch keeps the last
# reading rather than blanking the item; it stays hidden until one succeeds.

case "${SENDER:-}:${BUTTON:-}" in
  mouse.clicked:right)
    "$HOME/.config/dotfiles/status.sh" weather
    exit 0
    ;;
  mouse.clicked:other) ;;
  mouse.clicked:*)
    "$HOME/.config/aerospace/launch-or-focus.sh" --new Ghostty --args --wait-after-command=true -e curl -s --proto '=https' "https://wttr.in/?F"
    exit 0
    ;;
esac

BODY=$(curl -fsS --proto '=https' --max-time 5 'https://wttr.in/?format=%t|%C' 2>/dev/null) || exit 0
TEMP=${BODY%%|*}
CONDITION=${BODY#*|}
[[ -n $TEMP && $BODY == *"|"* ]] || exit 0

case "$CONDITION" in
  *[Tt]hunder*)                       ICON="󰖓" ;;
  *[Ss]now*|*[Ss]leet*|*[Ii]ce*)      ICON="󰖘" ;;
  *[Rr]ain*|*[Dd]rizzle*|*[Ss]hower*) ICON="󰖗" ;;
  *[Ff]og*|*[Mm]ist*|*[Hh]aze*)       ICON="󰖑" ;;
  *[Pp]artly*)                        ICON="󰖕" ;;
  *[Cc]loud*|*[Oo]vercast*)           ICON="󰖐" ;;
  *)                                  ICON="󰖙" ;;
esac

sketchybar --set "$NAME" drawing=on icon="$ICON" label="${TEMP#+}"
