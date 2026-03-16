#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Hotkeys Cheatsheet
# @raycast.mode fullOutput
# @raycast.packageName Keyboard

echo "── Keyboard Layout ────────────────────────────────────────
Option key = SUPER (AeroSpace / window management)
Command key = Alt (tmux)

── AeroSpace (Option = SUPER) ────────────────────────────
Option + Space          Raycast launcher
Option + 1–9           Switch workspace 1–9
Option + S              Switch to scratchpad (workspace 10)
Option + arrows         Focus window
Option + Shift+arrows   Move window
Option + Shift + 1–9   Move window to workspace
Option + Shift+0       Move window to scratchpad (workspace 10)
Option + W              Close window
Option + F              Fullscreen
Option + T              Toggle floating/tiling
Option + J              Toggle split direction
Option + L              Toggle layout
Option + K              Hotkeys cheatsheet (Raycast)
Option + ,              Toggle Notification Center
Option + Escape         Apple menu (Raycast)
Option + - / =          Resize width
Option + Shift + - / =  Resize height
Option + Tab            Next workspace
Option + Shift+Tab      Previous workspace
Option + Ctrl+Tab       Former workspace
Option + Enter          New Ghostty window
Option + Shift+Enter    New Chrome window
Option + Shift+N        New Zed window
Option + Shift+C        Open Google Calendar
Option + Shift+E        Open Gmail
Option + Shift+G        Open WhatsApp
Option + Shift+M        Open Spotify
Option + Shift+O        Open Obsidian
Option + Shift+F        Open Finder
Option + Shift+/        Open 1Password
Option + Shift+A        Open Claude
Option + Shift+D        LazyDocker in Ghostty
Option + Shift+Cmd+B    Chrome incognito
Option + Ctrl+C         CleanShot all-in-one
Option + Ctrl+L         Lock screen
Option + Ctrl+T         btop in Ghostty
Option + Ctrl+V         Clipboard history (Raycast)
Option + Ctrl+A         Sound preferences
Option + Ctrl+B         Bluetooth preferences
Option + Ctrl+W         Wi-Fi preferences
Option + Ctrl+E         Emoji picker (Raycast)
Option + Ctrl+X         Monologue (dictation)
Option + Ctrl+,         Toggle Do Not Disturb
Option + Cmd+Space      Workspace menu
Option + Cmd+Enter      Ghostty + tmux session

── tmux (prefix = Ctrl+Space) ─────────────────────────────
prefix + h / v      Split horizontal / vertical
prefix + x / k      Kill pane / window
prefix + c          New window
prefix + r / R      Rename window / session
prefix + [          Copy mode  (v select, y copy)
Ctrl+Alt+arrows     Navigate panes
Cmd + 1–9           Switch window
Cmd + Left/Right    Prev / next window
Cmd + Up/Down       Prev / next session

── Ghostty (terminal splits & pane nav) ──────────────────
Ctrl+Shift + E          Split down
Ctrl+Shift + O          Split right
Ctrl+Shift + T          New tab
Ctrl+Shift + 1–9        Go to tab 1–9
Ctrl+Shift + Left/Right Prev / next tab
Ctrl+Cmd + arrows       Navigate tmux panes
Ctrl+Cmd+Shift + arrows Resize tmux panes"
