#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Hotkeys Cheatsheet
# @raycast.mode fullOutput
# @raycast.packageName Keyboard

# Rendered from the README's "Workspace layout" and "Hotkeys" tables, so the
# README is the one copy to keep in sync with aerospace.toml. Each table becomes
# a section named after the heading above it; prose between tables is skipped.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Code/sogamoso/dotfiles}"
README="$DOTFILES/README.md"

if [[ ! -r $README ]]; then
  echo "Can't read $README — set DOTFILES to the checkout"
  exit 1
fi

awk '
  BEGIN { B = "\033[1m"; D = "\033[2m"; C = "\033[36m"; R = "\033[0m" }

  # awk counts bytes, so measure and pad by hand to keep ─, → and – aligned
  function width(s) {
    gsub(/[\300-\367][\200-\277]+/, "x", s)
    return length(s)
  }

  function repeat(s, n,   out) {
    while (n-- > 0) out = out s
    return out
  }

  function heading(title) {
    pending = ""
    printf "\n%s%s── %s %s%s\n", B, C, title, repeat("─", 52 - width(title)), R
  }

  function cell(s) {
    gsub(/`/, "", s)
    gsub(/\[[^]]*\]\([^)]*\)/, "", s)
    gsub(/^ +| +$/, "", s)
    return s
  }

  function flush(   n, f, i, key, desc) {
    if (pending == "") return
    n = split(pending, f, "|")
    desc = cell(f[3])
    for (i = 4; i < n; i++) desc = desc " · " cell(f[i])
    key = cell(f[2])
    printf "%s%s%s %s%s%s\n", B, key repeat(" ", 28 - width(key)), R, D, desc, R
    pending = ""
  }

  /^#### / {
    flush()
    title = substr($0, 6)
    on = (title == "Workspace layout" || title == "Hotkeys")
    if (on) heading(title == "Hotkeys" ? "Keyboard layout" : title)
    next
  }
  /^##?#? / { flush(); on = 0; next }
  !on { next }

  /^##### / { flush(); heading(substr($0, 7)); next }
  /^\|[-| ]+\|$/ { pending = ""; next }  # separator: the row before it was the header
  /^\|/ { flush(); pending = $0; next }
  { flush() }
  END { flush() }
' "$README"
