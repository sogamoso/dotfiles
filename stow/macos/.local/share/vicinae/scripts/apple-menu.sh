#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Apple Menu
# @vicinae.mode silent
# @vicinae.packageName System

osascript -e '
tell application "System Events"
  tell application process "Finder"
    set appleMenu to menu bar item 1 of menu bar 1
    if (exists menu 1 of appleMenu) and (value of attribute "AXVisibleChildren" of menu 1 of appleMenu) is not {} then
      key code 53 -- Escape to dismiss
    else
      click appleMenu
    end if
  end tell
end tell'
