#!/usr/bin/env bash

PAGE_SIZE=$(vm_stat | awk '/page size of/{print $8}')
TOTAL=$(sysctl -n hw.memsize)
MEM=$(vm_stat | awk -v ps="$PAGE_SIZE" -v total="$TOTAL" '
  /Pages active/   { active = $3 }
  /Pages wired/    { wired  = $4 }
  END { gsub(/\./, "", active); gsub(/\./, "", wired); printf "%.0f", (active + wired) * ps / total * 100 }
')

if [ "$MEM" -gt 80 ]; then
  COLOR=0xfff7768e
elif [ "$MEM" -gt 50 ]; then
  COLOR=0xffe0af68
else
  COLOR=0xffa9b1d6
fi

sketchybar --set "$NAME" icon="󰍛" icon.color=$COLOR label.drawing=off
