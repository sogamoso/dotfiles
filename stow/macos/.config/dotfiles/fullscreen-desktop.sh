#!/usr/bin/env bash
# Toggle a full screen desktop: hide SketchyBar and drop AeroSpace's gaps
# together. Ported from Omarchy's `omarchy toggle fullscreen desktop`
# (Super+Ctrl+Alt+F, basecamp/omarchy#10672).
#
# AeroSpace only reads gaps from its config, so this rewrites them in
# aerospace.toml and reloads. The pin-aerospace-gap git filter keeps those
# edits out of commits, and sketchybarrc and sync_aerospace_gap.sh check the
# state file, so a bar reload (on a display change, say) stays full screen.
set -euo pipefail

STATE="${TMPDIR:-/tmp}/dotfiles-fullscreen-desktop"
# Resolved because macOS sed won't edit in place through a symlink
CFG="$(readlink -f "$HOME/.config/aerospace/aerospace.toml")"
GAP=10  # matches [gaps] in aerospace.toml and the git filter

set_gaps() {
  sed -i '' -E \
    -e "s/^(inner\.(horizontal|vertical)[[:space:]]*=).*/\1 $1/" \
    -e "s/^(outer\.(left|bottom|right)[[:space:]]*=).*/\1 $1/" \
    "$CFG"
}

if [[ -e $STATE ]]; then
  rm -f "$STATE"
  set_gaps "$GAP"
  sketchybar --bar hidden=off
  # Puts outer.top back to fit the bar and reloads AeroSpace if it changed
  CONFIG_DIR="$HOME/.config/sketchybar" "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
else
  touch "$STATE"
  set_gaps 0
  sed -i '' -E "s/^(outer\.top[[:space:]]*=).*/\1 0/" "$CFG"
  sketchybar --bar hidden=on
fi
aerospace reload-config
