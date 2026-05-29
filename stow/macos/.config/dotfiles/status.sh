#!/usr/bin/env bash
# Status notifications — time, battery, weather.
# Ported from Omarchy's omarchy-battery-status, omarchy-weather-status,
# and the inline `date` time binding in utilities.conf.
#
# Usage:
#   status.sh time
#   status.sh battery
#   status.sh weather
set -euo pipefail

GROUP_ID="dotfiles-status"

notify() {
  terminal-notifier -title "$1" -message "${2:-}" \
    -group "$GROUP_ID" >/dev/null 2>&1
}

cmd_time() {
  notify "$(date +'%A %H:%M')" "$(date +'%d %B %Y  ·  Week %V')"
}

cmd_battery() {
  local line pct state remaining body
  line=$(pmset -g batt | tail -1)
  pct=$(grep -oE '[0-9]+%' <<<"$line" | head -1)
  state=$(grep -oE 'charged|charging|discharging|finishing charge|AC attached' <<<"$line" | head -1)
  remaining=$(grep -oE '[0-9]+:[0-9]{2}' <<<"$line" | head -1)

  body="${pct:-unknown}"
  [[ -n $state ]] && body+=" · $state"
  [[ -n $remaining && $remaining != "0:00" ]] && body+=" · $remaining left"
  notify "Battery" "$body"
}

cmd_weather() {
  local body
  body=$(curl -fsS --max-time 5 'wttr.in/?format=%c+%t+%C' 2>/dev/null) \
    || { notify "Weather" "Failed to fetch"; return 1; }
  notify "Weather" "$body"
}

case "${1:-}" in
  time)    cmd_time ;;
  battery) cmd_battery ;;
  weather) cmd_weather ;;
  *)       echo "Usage: $0 {time | battery | weather}" >&2; exit 64 ;;
esac
