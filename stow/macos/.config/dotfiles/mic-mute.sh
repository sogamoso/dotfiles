#!/usr/bin/env bash
# Toggle microphone input volume (mute / restore previous level).
# Ported from Omarchy's omarchy-audio-input-mute.
#
# macOS has no native global mic-mute hotkey, so this drives the system
# input volume via osascript. The previous level is stashed in $TMPDIR
# so unmuting restores it instead of jumping to 100%.
set -euo pipefail

STATE_FILE="${TMPDIR:-/tmp}/dotfiles-mic-mute.state"
GROUP_ID="dotfiles-mic-mute"

source "$HOME/.config/dotfiles/lib/notify.sh"

current=$(osascript -e 'input volume of (get volume settings)')

if [[ $current -eq 0 ]]; then
  prev=$(cat "$STATE_FILE" 2>/dev/null || echo 100)
  osascript -e "set volume input volume $prev"
  notify "Mic" "Microphone unmuted (${prev}%)"
else
  echo "$current" >"$STATE_FILE"
  osascript -e 'set volume input volume 0'
  notify "Mic" "Microphone muted"
fi
