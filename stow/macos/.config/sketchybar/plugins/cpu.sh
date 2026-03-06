#!/usr/bin/env bash

CPU=$(top -l 1 | awk '/CPU usage/{gsub(/%/,"",$3); gsub(/%/,"",$5); printf "%.0f", $3+$5}')

if [ "$CPU" -gt 80 ]; then
  COLOR=0xfff7768e
elif [ "$CPU" -gt 50 ]; then
  COLOR=0xffe0af68
else
  COLOR=0xffa9b1d6
fi

sketchybar --set "$NAME" icon="󰻠" icon.color=$COLOR label="${CPU}%"
