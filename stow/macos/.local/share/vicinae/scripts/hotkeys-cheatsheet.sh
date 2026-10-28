#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Cheatsheet - Hotkeys
# @vicinae.mode fullOutput
# @vicinae.packageName Keyboard

# Rendered from the README's "Workspace layout" and "Hotkeys" tables, so the
# README is the one copy to keep in sync with aerospace.toml. Each table becomes
# a section named after the heading above it; prose between tables is skipped,
# and so is a heading with no table under it.
#
# Like Omarchy's SUPER+K, SUPER+ALT+K and SUPER+CTRL+K, tmux and herdr get
# cheatsheets of their own, from the README's "tmux" and "herdr" sections:
# tmux-cheatsheet.sh and herdr-cheatsheet.sh run this with CHEATSHEET set.
set -euo pipefail
source "$HOME/.config/dotfiles/lib/cheatsheet.sh"

DOTFILES="${DOTFILES:-$HOME/Work/sogamoso/dotfiles}"
[[ -d $DOTFILES ]] || DOTFILES="$HOME/Code/sogamoso/dotfiles"  # a machine not yet moved to ~/Work
README="$DOTFILES/README.md"

if [[ ! -r $README ]]; then
  echo "Can't read $README — set DOTFILES to the checkout"
  exit 1
fi

case ${CHEATSHEET:-hotkeys} in
  hotkeys) title="Cheatsheet - Hotkeys" ;;
  *) title="Cheatsheet - $CHEATSHEET" ;;
esac

# Turn the tables into the `## Section` and tab separated lines cheatsheet reads
awk -v mode="${CHEATSHEET:-hotkeys}" '
  # Held back until the first row, so a heading over prose alone never prints
  function heading(title) {
    pending = ""
    title_pending = title
  }

  function cell(s) {
    gsub(/`/, "", s)
    gsub(/\[[^]]*\]\([^)]*\)/, "", s)
    gsub(/^ +| +$/, "", s)
    return s
  }

  function flush(   n, f, i, desc) {
    if (pending == "") return
    n = split(pending, f, "|")
    desc = cell(f[3])
    for (i = 4; i < n; i++) desc = desc " · " cell(f[i])
    if (title_pending != "") { print "## " title_pending; title_pending = "" }
    print cell(f[2]) "\t" desc
    pending = ""
  }

  /^#### / {
    flush()
    title = substr($0, 6)
    if (mode == "hotkeys") on = (title == "Workspace layout" || title == "Hotkeys")
    else on = (title == mode)
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
' "$README" | cheatsheet "$title"
