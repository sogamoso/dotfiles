#!/usr/bin/env bash

# Don't close via mouse events while keyboard nav is active
[ -f /tmp/sketchybar_menu_keyboard ] && exit 0

sketchybar --set apple_menu popup.drawing=off
