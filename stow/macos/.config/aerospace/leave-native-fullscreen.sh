#!/usr/bin/env bash
# Run a window command, first taking the focused window out of macOS full screen
# if it's in it.
#
# Option+F uses macOS full screen, which moves the window to its own Space and
# out of AeroSpace's tree, so swap, move, layout, resize and fullscreen all fail
# on it. On Omarchy full screen is just a window state and those keys act on the
# window directly; leaving full screen first gets the same result.
#
# Usage: leave-native-fullscreen.sh <command> [args...]
#   e.g. leave-native-fullscreen.sh aerospace swap left --swap-focus
set -euo pipefail

# AeroSpace marks the window as back in its tree as soon as it asks macOS to
# leave full screen, a second before the exit animation ends. Acting on it then
# (moving it to another workspace, say) interrupts the animation and strands the
# app in full screen, so wait on macOS's own AXFullScreen instead.
still_fullscreen() {
  [[ $(osascript -e '
tell application "System Events"
  tell (first application process whose frontmost is true)
    value of attribute "AXFullScreen" of window 1
  end tell
end tell' 2>/dev/null) == "true" ]]
}

if [[ $(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null) == "macos_native_fullscreen" ]]; then
  aerospace macos-native-fullscreen off
  sleep 0.3
  for _ in {1..30}; do
    still_fullscreen || break
    sleep 0.1
  done
  # The Space transition settles a beat after the window reports windowed
  sleep 0.2
fi

exec "$@"
