#!/usr/bin/env bash

CPU=$(top -l 1 | awk '/CPU usage/{gsub(/%/,"",$3); gsub(/%/,"",$5); printf "%.0f", $3+$5}')

sketchybar --set "$NAME" icon="󰻠" label="${CPU}%"
