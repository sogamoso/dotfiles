#!/bin/bash

if [ "$BUTTON" = "right" ]; then
  # Toggle mute (same as Omarchy's pamixer -t)
  osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
else
  # Open Sound preferences (maps to Omarchy's omarchy-launch-audio)
  open "x-apple.systempreferences:com.apple.preference.sound"
fi

# Refresh the volume icon
sketchybar --trigger volume_change
