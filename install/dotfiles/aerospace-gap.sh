#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# sketchybar rewrites outer.top on every start (8 undocked, bar height + 8
# docked), writing through the stow symlink into the tracked file. Pin the
# value git sees so docking stops polluting unrelated commits. The other gaps
# are pinned too, since fullscreen-desktop.sh zeroes them while it's on.
# Trade-off: a deliberate gap change won't stage either — edit the numbers here
# to move them.
git -C "$REPO_DIR" config filter.pin-aerospace-gap.clean \
  "sed -E -e 's/^outer\.top[[:space:]]*=.*/outer.top        = 38/' -e 's/^((inner|outer)\.(horizontal|vertical|left|bottom|right)[[:space:]]*=).*/\1 10/'"
