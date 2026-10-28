#!/usr/bin/env bash
# Centre a window on the screen it's on, keeping its size, the way Omarchy
# centres the floating windows it opens. AeroSpace floats a window where the app
# put it and has no command to centre one, so its window rules run this.
#
# Usage:
#   centre-window.sh [bundle_id]   the app's front window, or the frontmost app's
set -euo pipefail

# AppKit counts y up from the bottom of the primary screen; window positions
# count down from its top, hence the flip.
osascript -l JavaScript - "${1:-}" <<'EOF' >/dev/null
ObjC.import("AppKit")
function run([bundleId]) {
  const events = Application("System Events")
  const procs = bundleId
    ? events.processes.whose({ bundleIdentifier: bundleId })
    : events.processes.whose({ frontmost: true })
  // A window just detected may not be on screen yet
  let win
  for (let i = 0; i < 20 && !win; i++) {
    if (procs.length > 0 && procs[0].windows.length > 0) win = procs[0].windows[0]
    else delay(0.05)
  }
  if (!win) return
  const visible = $.NSScreen.mainScreen.visibleFrame
  const primaryHeight = $.NSScreen.screens.objectAtIndex(0).frame.size.height
  const top = primaryHeight - (visible.origin.y + visible.size.height)
  const [width, height] = win.size()
  win.position = [
    Math.round(visible.origin.x + (visible.size.width - width) / 2),
    Math.round(top + (visible.size.height - height) / 2),
  ]
}
EOF
