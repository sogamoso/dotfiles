#!/usr/bin/env bash

BATT=$(pmset -g batt)

# Desktop Mac (no internal battery) → hide entirely
if ! echo "$BATT" | grep -q "InternalBattery"; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

PERCENTAGE=$(echo "$BATT" | grep -Eo "[0-9]+%" | head -1 | cut -d% -f1)
[ -z "$PERCENTAGE" ] && exit 0

TIME_REMAINING=$(echo "$BATT" | grep -Eo '[0-9]+:[0-9]+ remaining' | grep -Eo '[0-9]+:[0-9]+')

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
    sketchybar --set "$NAME" drawing=on icon="󰂅" icon.color=0xffa9b1d6 label.drawing=off
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
    sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color=0xffa9b1d6 label.drawing=off
    exit 0
    ;;
  discharging)
    if   [ "$PERCENTAGE" -gt 80 ]; then ICON="󰁹"
    elif [ "$PERCENTAGE" -gt 60 ]; then ICON="󰂀"
    elif [ "$PERCENTAGE" -gt 40 ]; then ICON="󰁾"
    elif [ "$PERCENTAGE" -gt 20 ]; then ICON="󰁼"
    else                                 ICON="󰁺"
    fi

    if   [ "$PERCENTAGE" -le 10 ]; then COLOR=0xfff7768e  # critical
    elif [ "$PERCENTAGE" -le 20 ]; then COLOR=0xffe0af68  # warning
    else                                 COLOR=0xffa9b1d6  # normal
    fi

    if [ "$PERCENTAGE" -le 20 ]; then
      LABEL="${TIME_REMAINING:-${PERCENTAGE}%}"
      sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR" label.drawing=on
    else
      sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" label.drawing=off
    fi
    ;;
esac
