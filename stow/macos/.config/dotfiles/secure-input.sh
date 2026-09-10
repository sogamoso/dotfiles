#!/usr/bin/env bash
# Report which app is holding macOS Secure Input.
#
# While Secure Input is active no other app can read key events, so every
# AeroSpace hotkey goes dead and AeroSpace puts up its "cannot respond to
# keyboard shortcuts" panel. macOS names the owning process in the console
# session dictionary but exposes no way to release it, so this only diagnoses
# — quitting or defocusing the offending app is the fix.
#
# Deliberately has no AeroSpace binding: AeroSpace reads keys through an event
# tap, which is the very thing Secure Input blocks, so the binding would be
# dead exactly when it is needed. Invoke from Raycast or a terminal.
set -euo pipefail

GROUP_ID="dotfiles-secure-input"

# Tolerate a failing notifier: terminal-notifier exits non-zero when its
# notification permission is off, and the stdout line below is the point.
notify() {
  terminal-notifier -title "$1" -message "${2:-}" \
    -group "$GROUP_ID" >/dev/null 2>&1 || true
}

report() {
  notify "$1" "$2"
  echo "$1: $2"
}

session=$(ioreg -d 1 -k IOConsoleUsers -w 0)
pid=$(sed -n 's/.*"kCGSSessionSecureInputPID"=\([0-9]*\).*/\1/p' <<<"$session")

if [[ -z $pid ]]; then
  report "Secure Input" "Not active — hotkeys should work"
  exit 0
fi

# lsappinfo names GUI apps; loginwindow and friends only show up in ps.
name=$(lsappinfo info -only name "$pid" 2>/dev/null \
  | sed -n 's/.*"LSDisplayName"="\(.*\)"/\1/p' || true)
if [[ -z $name ]]; then
  name=$(ps -p "$pid" -o comm= 2>/dev/null || true)
  name=${name##*/}
fi

report "Secure Input active" "${name:-PID $pid} is blocking hotkeys (PID $pid)"
