#!/usr/bin/env bash
# Open Fastmail and switch to the requested view via Fastmail's
# global Shift+G shortcut. Pass "m" for Mail or "c" for Calendar.
set -euo pipefail

tab="${1:-m}"

osascript <<EOF
tell application "Fastmail" to activate
delay 0.25
tell application "System Events"
  keystroke "G" using {shift down}
  delay 0.05
  keystroke "$tab"
end tell
EOF
