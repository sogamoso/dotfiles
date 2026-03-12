#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Hotkeys Cheatsheet
# @raycast.mode fullOutput
# @raycast.packageName Keyboard

echo "── Keyboard Layout ────────────────────────────────────────
Option key = SUPER (AeroSpace / window management)
Command key = Alt (tmux / AltTab)

── AeroSpace (Option = SUPER) ────────────────────────────
Option + 1–9 / 0       Switch workspace (10 = scratchpad)
Option + Shift + 1–9   Move window to workspace
Option + arrows         Focus window
Option + Shift+arrows   Move window
Option + Tab / S+Tab    Next / prev workspace
Option + W              Close window
Option + F              Fullscreen
Option + T              Toggle floating
Option + J              Toggle split direction
Option + L              Toggle layout
Option + - / =          Resize width
Option + Shift - / =    Resize height
Option + Enter          New Ghostty window
Option + Shift+Enter    New Chrome window
Option + Shift+N        New Zed window
Option + Space          Raycast launcher
Cmd + Tab               Cycle windows (AltTab)

── tmux (prefix = Ctrl+Space) ─────────────────────────────
prefix + h / v      Split horizontal / vertical
prefix + x / k      Kill pane / window
prefix + c          New window
prefix + r / R      Rename window / session
prefix + [          Copy mode  (v select, y copy)
Ctrl+Alt+arrows     Navigate panes
Cmd + 1–9           Switch window
Cmd + Left/Right    Prev / next window
Cmd + Up/Down       Prev / next session"
