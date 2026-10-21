#!/usr/bin/env bash
# Pop the focused window out, as Omarchy's SUPER+O (omarchy-hyprland-window-pop)
# does: float it, size it to 1300x900 (or 90% of a smaller screen), centre it,
# and pin it so it follows you to every workspace. Run again on a popped window
# to put it back in the tiling layout.
#
# AeroSpace has no sticky windows, so pinning is done here: popped window ids
# are kept in a state file, and `window-pop.sh follow`, run from AeroSpace's
# exec-on-workspace-change, moves them to each workspace you switch to.
#
# Usage:
#   window-pop.sh          toggle the focused window
#   window-pop.sh follow   move pinned windows to the focused workspace
set -euo pipefail

STATE="${TMPDIR:-/tmp}/dotfiles-pinned-windows"

# Centre the focused window at Omarchy's pop size on the screen it's on.
# AppKit counts y up from the bottom of the primary screen; window positions
# count down from its top, hence the flip.
centre_focused_window() {
  osascript -l JavaScript -e '
ObjC.import("AppKit")
const screen = $.NSScreen.mainScreen
const visible = screen.visibleFrame
const primaryHeight = $.NSScreen.screens.objectAtIndex(0).frame.size.height
const width = Math.min(1300, visible.size.width * 0.9)
const height = Math.min(900, visible.size.height * 0.9)
const top = primaryHeight - (visible.origin.y + visible.size.height)
const proc = Application("System Events").processes.whose({ frontmost: true })[0]
const win = proc.windows[0]
win.size = [Math.round(width), Math.round(height)]
win.position = [
  Math.round(visible.origin.x + (visible.size.width - width) / 2),
  Math.round(top + (visible.size.height - height) / 2),
]' >/dev/null
}

toggle() {
  local id
  id=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null) || return 0
  [[ -n $id ]] || return 0

  if grep -qx "$id" "$STATE" 2>/dev/null; then
    grep -vx "$id" "$STATE" >"$STATE.tmp" || true
    mv "$STATE.tmp" "$STATE"
    aerospace layout --window-id "$id" tiling
  else
    echo "$id" >>"$STATE"
    aerospace layout --window-id "$id" floating
    centre_focused_window || true
  fi
}

# Runs on every workspace change, so it drops windows that have since closed and
# never fails the hook over one window it can't move.
follow() {
  [[ -s $STATE ]] || return 0
  local workspace alive id
  workspace="${AEROSPACE_FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
  alive=$(aerospace list-windows --monitor all --format '%{window-id}')
  : >"$STATE.tmp"
  while read -r id; do
    grep -qx "$id" <<<"$alive" || continue
    echo "$id" >>"$STATE.tmp"
    aerospace move-node-to-workspace --window-id "$id" "$workspace" 2>/dev/null || true
  done <"$STATE"
  mv "$STATE.tmp" "$STATE"
}

case "${1:-toggle}" in
  toggle) toggle ;;
  follow) follow ;;
  *) echo "Usage: $0 [toggle | follow]" >&2; exit 64 ;;
esac
