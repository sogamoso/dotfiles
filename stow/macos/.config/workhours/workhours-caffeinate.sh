#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="com.sogamoso.workhours.caffeinate-run"
DOMAIN="gui/$(id -u)"

# Weekdays 08:00–19:00, matching the pmset wake and the sleep-if-idle agent.
# Laptops only; the Mac mini never loads these agents and stays awake via pmset.
START_HOUR=8
END_HOUR=19

running() {
  launchctl list "$LABEL" 2>/dev/null | grep -q '"PID"'
}

in_work_hours() {
  local weekday hour
  weekday=$(date +%u)
  hour=$((10#$(date +%H)))
  (( weekday <= 5 && hour >= START_HOUR && hour < END_HOUR ))
}

if ! in_work_hours; then
  reason="Outside work hours"
elif ! "$SCRIPT_DIR/macos-on-ac-power"; then
  reason="On battery"
else
  if running; then
    echo "On AC in work hours, caffeinate already running — skipping"
  else
    echo "On AC in work hours — starting caffeinate"
    launchctl kickstart "$DOMAIN/$LABEL"
  fi
  exit 0
fi

if running; then
  echo "$reason — stopping caffeinate"
  launchctl kill SIGTERM "$DOMAIN/$LABEL"
else
  echo "$reason, caffeinate not running — nothing to do"
fi
