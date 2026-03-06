#!/usr/bin/env bash

open -a "Activity Monitor"
sleep 0.4
osascript -e 'tell application "System Events" to tell process "Activity Monitor" to keystroke "1" using command down'
