#!/usr/bin/env bash
# Toggle microphone input volume (mute / restore previous level).
# Ported from Omarchy's omarchy-audio-input-mute.
#
# macOS has no native global mic-mute hotkey, so this drives the system
# input volume via osascript. The previous level is stashed in $TMPDIR
# so unmuting restores it instead of jumping to 100%.
set -euo pipefail

STATE_FILE="${TMPDIR:-/tmp}/dotfiles-mic-mute.state"

current=$(osascript -e 'input volume of (get volume settings)')

if [[ $current -eq 0 ]]; then
  prev=$(cat "$STATE_FILE" 2>/dev/null || echo 100)
  osascript -e "set volume input volume $prev"
  osascript -e "display notification \"Microphone unmuted (${prev}%)\" with title \"Mic\""
else
  echo "$current" >"$STATE_FILE"
  osascript -e 'set volume input volume 0'
  osascript -e "display notification \"Microphone muted\" with title \"Mic\""
fi
