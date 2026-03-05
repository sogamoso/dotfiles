#!/usr/bin/env bash

PAGE_SIZE=$(vm_stat | awk '/page size of/{print $8}')
TOTAL=$(sysctl -n hw.memsize)
USED=$(vm_stat | awk -v ps="$PAGE_SIZE" '
  /Pages active/   { active = $3 }
  /Pages wired/    { wired  = $4 }
  END { gsub(/\./, "", active); gsub(/\./, "", wired); printf "%.0f", (active + wired) * ps }
')
PCT=$(awk "BEGIN {printf \"%.0f\", $USED/$TOTAL*100}")

sketchybar --set "$NAME" icon="󰍛" label="${PCT}%"
