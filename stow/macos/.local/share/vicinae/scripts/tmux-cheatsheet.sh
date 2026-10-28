#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title tmux Cheatsheet
# @vicinae.mode fullOutput
# @vicinae.packageName Keyboard

# The README's tmux section, rendered by the hotkeys cheatsheet
# (Omarchy: SUPER+ALT+K).
set -euo pipefail

CHEATSHEET=tmux exec "$(dirname "$0")/hotkeys-cheatsheet.sh"
