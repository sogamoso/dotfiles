#!/usr/bin/env bash
# Close every window across all workspaces, then jump to workspace 1.
# Mirrors Omarchy's CTRL+ALT+DEL behavior (omarchy-hyprland-window-close-all).
set -euo pipefail

aerospace list-windows --all --format '%{window-id}' \
  | xargs -I{} aerospace close --window-id {}
aerospace workspace 1
