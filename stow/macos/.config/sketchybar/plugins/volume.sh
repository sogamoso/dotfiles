#!/usr/bin/env bash

# Omarchy parity: left click opens the audio panel, right click mutes, scroll
# changes the volume. Changing it fires volume_change, which redraws the icon.
case "${SENDER:-}" in
  mouse.clicked)
    if [[ ${BUTTON:-} == "right" ]]; then
      osascript -e 'set volume output muted not (output muted of (get volume settings))'
    else
      open "x-apple.systempreferences:com.apple.Sound-Settings.extension"
    fi
    exit 0
    ;;
  mouse.scrolled)
    # Caps the rate rather than collapsing the swipe, so a long swipe still
    # travels further than a short one
    source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/common.sh"
    debounce volume-scroll 0.05 || exit 0
    [[ ${SCROLL_DELTA:-0} == -* ]] && STEP=-3 || STEP=3
    osascript -e "set volume output volume ((output volume of (get volume settings)) + $STEP)"
    exit 0
    ;;
esac

# Get volume using osascript with robust error handling
# Note: This is more stable than it appears - the API hasn't changed in years
VOLUME=$(osascript -e 'try
  output volume of (get volume settings)
on error
  0
end try' 2>/dev/null)

MUTED=$(osascript -e 'try
  output muted of (get volume settings)
on error
  false
end try' 2>/dev/null)

# Handle missing value or empty
if [[ -z $VOLUME ]] || [[ $VOLUME == "missing value" ]]; then
  VOLUME=0
fi
if [[ -z $MUTED ]] || [[ $MUTED == "missing value" ]]; then
  MUTED=false
fi

# Determine icon based on volume level
if [[ $MUTED == "true" ]] || (( VOLUME == 0 )); then
  ICON="󰝟"
elif (( VOLUME > 60 )); then
  ICON="󰕾"
elif (( VOLUME > 10 )); then
  ICON="󰖀"
else
  ICON="󰕿"
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$ICON" \
  label.drawing=off
