#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title New Ghostty Window
# @raycast.mode silent
# @raycast.packageName Terminal

# Clear persisted macOS window position so Ghostty doesn't reopen in stale coords.
/usr/bin/defaults delete com.mitchellh.ghostty NSWindowLastPosition >/dev/null 2>&1 || true

open -na Ghostty
