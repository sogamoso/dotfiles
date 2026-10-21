#!/usr/bin/env bash

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/colors.sh"

# Omarchy parity: fixed icon, no color shifts, no labels — minimal.
# Click opens activity monitor (sketchybarrc click_script).
sketchybar --set "$NAME" icon="󰍛" icon.color=$TEXT label.drawing=off
