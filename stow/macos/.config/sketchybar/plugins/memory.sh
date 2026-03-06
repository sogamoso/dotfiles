#!/usr/bin/env bash

LEVEL=$(memory_pressure 2>/dev/null | awk '/system memory pressure is at/{print $(NF-1)}')

case "$LEVEL" in
  CRITICAL) COLOR=0xfff7768e ;;
  WARNING)  COLOR=0xffe0af68 ;;
  *)        COLOR=0xffa9b1d6 ;;
esac

sketchybar --set "$NAME" icon="󰍛" icon.color=$COLOR label.drawing=off
