#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="com.sogamoso.workhours.caffeinate-run"
DOMAIN="gui/$(id -u)"

running() {
  launchctl list "$LABEL" 2>/dev/null | grep -q '"PID"'
}

if "$SCRIPT_DIR/macos-on-ac-power"; then
  if running; then
    echo "On AC, caffeinate already running — skipping"
  else
    echo "On AC — starting caffeinate"
    launchctl kickstart "$DOMAIN/$LABEL"
  fi
else
  if running; then
    echo "On battery — stopping caffeinate"
    launchctl kill SIGTERM "$DOMAIN/$LABEL"
  else
    echo "On battery, caffeinate not running — nothing to do"
  fi
fi
