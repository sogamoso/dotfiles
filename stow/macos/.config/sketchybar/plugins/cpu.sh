#!/bin/bash

# Maps to Omarchy's cpu module:
#   icon: 󰍛 (always visible)
#   on-click: opens btop → on mac we open Activity Monitor
#
# Optionally show load color. Uncomment to tint icon under load.

LOAD=$(sysctl -n vm.loadavg | awk '{print int($2)}')
CORES=$(sysctl -n hw.ncpu)
USAGE_RATIO=$((LOAD * 100 / CORES))

COLOR="0xffa9b1d6"  # foreground
if [ "$USAGE_RATIO" -gt 80 ]; then
  COLOR="0xfff7768e"  # red
elif [ "$USAGE_RATIO" -gt 50 ]; then
  COLOR="0xffe0af68"  # yellow
fi

sketchybar --set "$NAME" icon.color="$COLOR"
