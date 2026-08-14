#!/usr/bin/env bash
# Show an indicator while something is holding the machine awake — either the
# workhours LaunchAgents or a manual `caffeinate`.
# Omarchy parity: Quattro's "stay awake" manual-state indicator.
set -u

if pgrep -x caffeinate >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
