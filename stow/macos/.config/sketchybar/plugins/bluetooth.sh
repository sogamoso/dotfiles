#!/usr/bin/env bash

# Omarchy parity:
#   format-connected     → 󰂱 (visible)
#   format-off/disabled  → 󰂲 (visible)
#   format               → "" (hidden when on but no device connected)
#   format-no-controller → "" (hidden on machines without bluetooth)
#
# Reads system_profiler rather than blueutil: without the Bluetooth privacy
# permission, which sketchybar never gets asked for, IOBluetooth answers
# "powered off, nothing connected" instead of failing, so blueutil showed the
# off icon while Bluetooth was on. system_profiler needs no permission.

# sketchybar runs under launchd, whose PATH has no Homebrew prefix
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

hide() { sketchybar --set "$NAME" drawing=off; exit 0; }

command -v jq >/dev/null 2>&1 || hide

BT_JSON=$(system_profiler -json SPBluetoothDataType 2>/dev/null)
BT_STATE=$(jq -r '.SPBluetoothDataType[0].controller_properties.controller_state // empty' <<<"$BT_JSON" 2>/dev/null)

# No controller, or nothing readable
[[ -n $BT_STATE ]] || hide

if [[ $BT_STATE != "attrib_on" ]]; then
  sketchybar --set "$NAME" drawing=on icon="󰂲" label.drawing=off
  exit 0
fi

CONNECTED=$(jq -r '.SPBluetoothDataType[0].device_connected // [] | length' <<<"$BT_JSON" 2>/dev/null)
if (( ${CONNECTED:-0} > 0 )); then
  sketchybar --set "$NAME" drawing=on icon="󰂱" label.drawing=off
else
  sketchybar --set "$NAME" drawing=off
fi
