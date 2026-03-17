#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if "$SCRIPT_DIR/macos-on-ac-power"; then
  # On AC — start caffeinate if not already running
  if pgrep -f "caffeinate -imu" >/dev/null 2>&1; then
    echo "caffeinate already running — skipping"
    exit 0
  fi
  echo "On AC — starting caffeinate"
  # Keep system awake for 11 hours (39600s); allow display to sleep (-imu, no -d)
  exec caffeinate -imu -t 39600
else
  # On battery — stop caffeinate if running
  if pkill -f "caffeinate -imu" 2>/dev/null; then
    echo "Switched to battery — stopped caffeinate"
  else
    echo "On battery, caffeinate not running — nothing to do"
  fi
fi
