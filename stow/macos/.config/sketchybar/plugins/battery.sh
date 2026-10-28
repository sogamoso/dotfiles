#!/usr/bin/env bash

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/colors.sh"

# Omarchy parity: left click opens the power panel, right click toggles the
# percentage, and the choice sticks across reloads
PERCENT_FILE="${TMPDIR:-/tmp}/dotfiles-sketchybar-battery-percent"
if [[ ${SENDER:-} == "mouse.clicked" ]]; then
  if [[ ${BUTTON:-} != "right" ]]; then
    open "x-apple.systempreferences:com.apple.Battery-Settings.extension"
    exit 0
  fi
  if [[ -e $PERCENT_FILE ]]; then rm -f "$PERCENT_FILE"; else touch "$PERCENT_FILE"; fi
fi

BATT=$(pmset -g batt)

# Desktop Mac (no internal battery) → hide entirely
if ! echo "$BATT" | grep -q "InternalBattery"; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

PERCENTAGE=$(echo "$BATT" | grep -Eo "[0-9]+%" | head -1 | cut -d% -f1)
[[ -z $PERCENTAGE ]] && exit 0

TIME_REMAINING=$(echo "$BATT" | grep -Eo '[0-9]+:[0-9]+ remaining' | grep -Eo '[0-9]+:[0-9]+')

# Shown beside the icon whenever the right-click toggle is on
if [[ -e $PERCENT_FILE ]]; then
  PERCENT_LABEL=(label="${PERCENTAGE}%" label.color=$TEXT label.drawing=on)
else
  PERCENT_LABEL=(label.drawing=off)
fi

# Classify state (mirrors Omarchy's format-{discharging,charging,plugged,full})
if echo "$BATT" | grep -q "; charged"; then
  STATE=full
elif echo "$BATT" | grep -q "; charging"; then
  STATE=charging
elif echo "$BATT" | grep -qE "; (AC attached; )?not charging"; then
  STATE=plugged
elif echo "$BATT" | grep -q "; discharging"; then
  STATE=discharging
else
  STATE=unknown
fi

case "$STATE" in
  plugged|unknown)
    # Omarchy parity: plugged but not actively charging → hide
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
  full)
    sketchybar --set "$NAME" drawing=on icon="󰂅" icon.color=$TEXT "${PERCENT_LABEL[@]}"
    exit 0
    ;;
  charging)
    case "$PERCENTAGE" in
      100)    ICON="󰂅" ;;
      9[0-9]) ICON="󰂋" ;;
      8[0-9]) ICON="󰂊" ;;
      7[0-9]) ICON="󰢞" ;;
      6[0-9]) ICON="󰂉" ;;
      5[0-9]) ICON="󰢝" ;;
      4[0-9]) ICON="󰂈" ;;
      3[0-9]) ICON="󰂇" ;;
      2[0-9]) ICON="󰂆" ;;
      *)      ICON="󰢜" ;;
    esac
    sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color=$TEXT "${PERCENT_LABEL[@]}"
    exit 0
    ;;
  discharging)
    if   (( PERCENTAGE > 80 )); then ICON="󰁹"
    elif (( PERCENTAGE > 60 )); then ICON="󰂀"
    elif (( PERCENTAGE > 40 )); then ICON="󰁾"
    elif (( PERCENTAGE > 20 )); then ICON="󰁼"
    else                                 ICON="󰁺"
    fi

    if   (( PERCENTAGE <= 10 )); then COLOR=$RED     # critical
    elif (( PERCENTAGE <= 20 )); then COLOR=$YELLOW  # warning
    else                                 COLOR=$TEXT    # normal
    fi

    if (( PERCENTAGE <= 20 )); then
      LABEL="${TIME_REMAINING:-${PERCENTAGE}%}"
      sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR" label.drawing=on
    else
      sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" "${PERCENT_LABEL[@]}"
    fi
    ;;
esac
