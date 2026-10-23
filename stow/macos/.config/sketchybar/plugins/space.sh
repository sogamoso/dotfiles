#!/usr/bin/env bash

# Omarchy parity for workspace indicators:
#   focused workspace        → dot glyph (󱓻), foreground color
#   inactive populated       → number, foreground color
#   empty workspaces 1–5     → number, muted (~0.5 opacity equivalent)
#   empty workspaces 6–9     → hidden entirely

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/colors.sh"

# Scrolling over any indicator steps through the same workspaces Option+Tab does
if [[ ${SENDER:-} == "mouse.scrolled" ]]; then
  source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/common.sh"
  debounce workspace-scroll 0.4 || exit 0
  # The delta can be fractional on a trackpad, which (( )) can't compare
  if [[ ${SCROLL_DELTA:-0} == -* ]]; then
    "$HOME/.config/aerospace/workspace_cycle.sh" next
  else
    "$HOME/.config/aerospace/workspace_cycle.sh" prev
  fi
  exit 0
fi

# MUTED stands in for Omarchy's opacity:0.5

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
POPULATED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | sort -u)

for i in {1..9}; do
  echo "$POPULATED" | grep -qw "$i" && IS_POP=1 || IS_POP=0
  [[ $i == "$FOCUSED" ]] && IS_FOC=1 || IS_FOC=0

  if (( i <= 5 )) || (( IS_POP == 1 )) || (( IS_FOC == 1 )); then
    if (( IS_FOC == 1 )); then
      sketchybar --set space.$i drawing=on icon="󱓻" icon.color=$TEXT
    elif (( IS_POP == 1 )); then
      sketchybar --set space.$i drawing=on icon="$i" icon.color=$TEXT
    else
      sketchybar --set space.$i drawing=on icon="$i" icon.color=$MUTED
    fi
  else
    sketchybar --set space.$i drawing=off
  fi
done
