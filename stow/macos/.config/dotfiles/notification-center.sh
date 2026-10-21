#!/usr/bin/env bash
# Toggle Notification Center from a second chord by sending Option+, — the macOS
# keyboard shortcut that already toggles it (System Settings → Keyboard →
# Keyboard Shortcuts → Mission Control). macOS allows one shortcut per action, and
# its menu bar items expose nothing to click on current macOS, so the keystroke
# is the only way in.
#
# The binding fires while Shift and Cmd are still held, which would turn the
# keystroke into the wrong chord, so it waits (up to 2s) for them to be released.
set -euo pipefail

osascript -l JavaScript -e '
ObjC.import("AppKit")
const held = $.NSEventModifierFlagShift | $.NSEventModifierFlagCommand
for (let i = 0; i < 100 && ($.NSEvent.modifierFlags & held); i++) delay(0.02)
Application("System Events").keyCode(43, { using: "option down" })
'
