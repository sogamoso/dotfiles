#!/usr/bin/env bash
# Status notifications — time, battery, weather.
# Ported from Omarchy's omarchy-battery-status, omarchy-weather-status,
# and the inline `date` time binding in utilities.conf.
#
# Usage:
#   status.sh time
#   status.sh battery
#   status.sh weather
#   status.sh worldclock
set -euo pipefail

GROUP_ID="dotfiles-status"

source "$HOME/.config/dotfiles/lib/notify.sh"

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
  body=$(curl -fsS --proto '=https' --max-time 5 'https://wttr.in/?format=%c+%t+%C' 2>/dev/null) \
    || { notify "Weather" "Failed to fetch"; return 1; }
  notify "Weather" "$body"
}

# Omarchy's world clock panel (Super+Ctrl+Alt+E) as a notification. The day
# is added only for a city where the date differs from here.
WORLD_CLOCK=(
  "Panama City|America/Panama"
  "Tegucigalpa|America/Tegucigalpa"
  "Mexico City|America/Mexico_City"
  "San Francisco|America/Los_Angeles"
  "New York|America/New_York"
)

cmd_worldclock() {
  local entry city zone when body="" today
  today=$(date +%F)
  for entry in "${WORLD_CLOCK[@]}"; do
    city=${entry%%|*}
    zone=${entry##*|}
    when=$(TZ=$zone date +%H:%M)
    [[ "$(TZ=$zone date +%F)" == "$today" ]] || when+=" $(TZ=$zone date +%a)"
    body+="${body:+  ·  }$city $when"
  done
  notify "World clock" "$body"
}

case "${1:-}" in
  time)    cmd_time ;;
  battery) cmd_battery ;;
  weather) cmd_weather ;;
  worldclock) cmd_worldclock ;;
  *)       echo "Usage: $0 {time | battery | weather | worldclock}" >&2; exit 64 ;;
esac
