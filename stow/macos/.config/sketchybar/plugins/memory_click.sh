#!/usr/bin/env bash

open -a "Activity Monitor"
osascript <<'EOF'
tell application "Activity Monitor" to activate
tell application "System Events"
    repeat 10 times
        try
            tell process "Activity Monitor"
                click menu item "Memory" of menu 1 of menu bar item "View" of menu bar 1
            end tell
            exit repeat
        on error
            delay 0.2
        end try
    end repeat
end tell
EOF
