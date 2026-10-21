#!/usr/bin/env bash
# Toggle Notification Center by clicking the menu bar clock, which opens it and,
# clicked again, closes it.
#
# Option+, already does this as a macOS keyboard shortcut, but macOS allows one
# shortcut per action, so a second chord has to go another way. Synthesizing
# Option+, from an AeroSpace binding doesn't work either: Shift and Cmd are still
# held when it fires, so the keystroke arrives as the wrong chord.
set -euo pipefail

osascript -e '
tell application "System Events"
  tell application process "ControlCenter"
    click (first menu bar item of menu bar 1 whose value of attribute "AXIdentifier" is "com.apple.menuextra.clock")
  end tell
end tell'
