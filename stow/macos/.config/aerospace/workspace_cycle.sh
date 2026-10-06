#!/usr/bin/env bash
# Usage: workspace_cycle.sh next|prev

case "${1:-}" in
  next) STEP=1 ;;
  prev) STEP=-1 ;;
  *) echo "Usage: $0 next|prev" >&2; exit 1 ;;
esac

CURRENT=$(aerospace list-workspaces --focused 2>/dev/null)

# Omarchy parity: cycle through 1-5 always + any populated 6-9 + currently focused
POPULATED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | sort -u)
VISIBLE=""
for ws in $(seq 1 9); do
  if (( ws <= 5 )) || echo "$POPULATED" | grep -qw "$ws" || [[ $ws == "$CURRENT" ]]; then
    VISIBLE="$VISIBLE $ws"
  fi
done

# Outside the cycle (the scratchpad), next starts at the first workspace and prev at the last
TARGET=$(echo "$VISIBLE" | awk -v cur="$CURRENT" -v step="$STEP" '{
  for (i=1; i<=NF; i++) {
    if ($i == cur) {
      print $((i - 1 + step + NF) % NF + 1)
      exit
    }
  }
  print (step > 0 ? $1 : $NF)
}')

aerospace workspace "$TARGET"
