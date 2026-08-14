#!/usr/bin/env bash
# Show spend for the active Claude Code billing block.
# Omarchy parity: Quattro's model-usage bar widget.
#
# Data comes from ccusage, which reads the local Claude Code JSONL transcripts.
# No API calls and no credentials involved. Hidden when no block is active,
# i.e. nothing has been billed in the current window.
set -u

# sketchybar runs under launchd, whose PATH has no Homebrew prefix, so both
# ccusage and jq are invisible without this.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

hide() { sketchybar --set "$NAME" drawing=off; exit 0; }

command -v ccusage >/dev/null 2>&1 || hide
command -v jq >/dev/null 2>&1 || hide

JSON=$(ccusage blocks --active --json 2>/dev/null) || hide

COST=$(printf '%s' "$JSON" | jq -r '.blocks[0].costUSD // empty' 2>/dev/null)
REMAINING=$(printf '%s' "$JSON" | jq -r '.blocks[0].projection.remainingMinutes // empty' 2>/dev/null)

[ -n "$COST" ] || hide

LABEL=$(printf '$%.2f' "$COST")

if [ -n "$REMAINING" ] && [ "$REMAINING" -gt 0 ] 2>/dev/null; then
  LABEL="$LABEL · $((REMAINING / 60))h$((REMAINING % 60))m"
fi

sketchybar --set "$NAME" drawing=on label="$LABEL"
