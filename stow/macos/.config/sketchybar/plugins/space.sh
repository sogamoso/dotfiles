#!/usr/bin/env bash

# Omarchy parity for workspace indicators:
#   focused workspace        → dot glyph (󱓻), foreground color
#   inactive populated       → number, foreground color
#   empty workspaces 1–5     → number, muted (~0.5 opacity equivalent)
#   empty workspaces 6–9     → hidden entirely

FG=0xffa9b1d6   # foreground
MUTED=0xff565f89  # faded ~ Omarchy's opacity:0.5

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
POPULATED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | sort -u)

for i in {1..9}; do
  echo "$POPULATED" | grep -qw "$i" && IS_POP=1 || IS_POP=0
  [ "$i" = "$FOCUSED" ] && IS_FOC=1 || IS_FOC=0

  if [ "$i" -le 5 ] || [ "$IS_POP" -eq 1 ] || [ "$IS_FOC" -eq 1 ]; then
    if [ "$IS_FOC" -eq 1 ]; then
      sketchybar --set space.$i drawing=on icon="󱓻" icon.color=$FG
    elif [ "$IS_POP" -eq 1 ]; then
      sketchybar --set space.$i drawing=on icon="$i" icon.color=$FG
    else
      sketchybar --set space.$i drawing=on icon="$i" icon.color=$MUTED
    fi
  else
    sketchybar --set space.$i drawing=off
  fi
done
