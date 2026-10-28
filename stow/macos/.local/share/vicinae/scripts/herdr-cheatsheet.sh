#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Cheatsheet - herdr
# @vicinae.mode fullOutput
# @vicinae.packageName Keyboard

# The README's herdr section, rendered by the hotkeys cheatsheet
# (Omarchy: SUPER+CTRL+K).
set -euo pipefail

CHEATSHEET=herdr exec "$(dirname "$0")/hotkeys-cheatsheet.sh"
