#!/usr/bin/env bash
# Toggle Ghostty's quick terminal, its drop-down console, as Omarchy's
# SUPER+grave toggles its Quake console.
#
# Bound in AeroSpace rather than as a Ghostty global keybind, which would need
# Ghostty running and Accessibility access of its own. Ghostty's AppleScript
# runs an action only on a terminal, so with none open this starts Ghostty, and
# the console drops down over its first window.
set -euo pipefail

GROUP_ID="dotfiles-quick-terminal"

toggle() {
  osascript -e 'tell application "Ghostty" to perform action "toggle_quick_terminal" on terminal 1' >/dev/null 2>&1
}

toggle && exit 0

open -a Ghostty
for _ in {1..50}; do
  toggle && exit 0
  sleep 0.1
done

source "$HOME/.config/dotfiles/lib/notify.sh"
notify "Ghostty" "Could not open the quick terminal"
exit 1
