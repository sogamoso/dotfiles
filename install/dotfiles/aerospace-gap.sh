#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# sketchybar rewrites outer.top on every start (8 undocked, bar height + 8
# docked), writing through the stow symlink into the tracked file. Pin the
# value git sees so docking stops polluting unrelated commits. Trade-off: a
# deliberate gap change won't stage either — edit the number here to move it.
git -C "$REPO_DIR" config filter.pin-aerospace-gap.clean \
  "sed -E 's/^outer\.top[[:space:]]*=.*/outer.top        = 38/'"
