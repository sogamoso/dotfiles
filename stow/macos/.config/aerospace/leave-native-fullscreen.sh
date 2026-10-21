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

if [[ $(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null) == "macos_native_fullscreen" ]]; then
  aerospace macos-native-fullscreen off
  # The exit animation takes about a second; the window rejoins the tree at its end
  for _ in {1..40}; do
    [[ $(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null) == "macos_native_fullscreen" ]] || break
    sleep 0.05
  done
fi

exec "$@"
