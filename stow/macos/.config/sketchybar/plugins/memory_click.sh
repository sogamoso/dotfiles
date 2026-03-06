#!/usr/bin/env bash

osascript <<'EOF'
tell application "Activity Monitor" to activate
tell application "System Events"
  tell process "Activity Monitor"
    repeat until (exists menu bar 1)
      delay 0.1
    end repeat
    click menu item "Memory" of menu "View" of menu bar 1
  end tell
end tell
EOF
