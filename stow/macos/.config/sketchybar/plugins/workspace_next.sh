#!/usr/bin/env bash

CURRENT=$(aerospace list-workspaces --focused 2>/dev/null)

# Omarchy parity: cycle through 1-5 always + any populated 6-9 + currently focused
POPULATED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | sort -u)
VISIBLE=""
for ws in $(seq 1 9); do
  if [ "$ws" -le 5 ] || echo "$POPULATED" | grep -qw "$ws" || [ "$ws" = "$CURRENT" ]; then
    VISIBLE="$VISIBLE $ws"
  fi
done

NEXT=$(echo "$VISIBLE" | awk -v cur="$CURRENT" '{
  for (i=1; i<=NF; i++) {
    if ($i == cur) {
      print $((i % NF) + 1)
      exit
    }
  }
  print $1
}')

aerospace workspace "$NEXT"
