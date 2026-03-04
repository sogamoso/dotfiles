#!/usr/bin/env bash

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    icon.color=0xff7aa2f7 \
    background.drawing=on
else
  sketchybar --set "$NAME" \
    icon.color=0xff565f89 \
    background.drawing=off
fi
