#!/usr/bin/env bash
# Launch an app, or focus it if already running.
#
# Usage:
#   launch-or-focus.sh [--new] [--here] <bundle_id_or_app_name> [open-args...]
#
# Targets containing a dot are treated as bundle IDs (open -b);
# otherwise they're treated as app names (open -a).
# --new forces a new instance (open -n).
# --here summons an existing window to the focused workspace instead of letting
# AeroSpace follow it to the workspace it already lives on.
#
# Anything after the target is passed through to `open` verbatim
# (e.g. `--args -e tmux new-session -A -s main`).
set -euo pipefail

new=false
here=false
while true; do
  case "${1:-}" in
    --new)  new=true;  shift ;;
    --here) here=true; shift ;;
    *)      break ;;
  esac
done

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [--new] [--here] <bundle_id_or_app_name> [open-args...]" >&2
  exit 64
fi

target="$1"
shift

flags=()
$new && flags+=("-n")
if [[ "$target" == *.* ]]; then
  flags+=("-b" "$target")
else
  flags+=("-a" "$target")
fi

# A window that already exists lives on some workspace, and plain `open` makes
# AeroSpace jump there. Move it to the workspace in front of you instead. With
# no window yet there is nothing to move: fall through and let `open` create one,
# which lands here anyway.
if $here && ! $new; then
  if [[ "$target" == *.* ]]; then
    ids=$(aerospace list-windows --monitor all --app-bundle-id "$target" --format '%{window-id}' 2>/dev/null || true)
  else
    ids=$(aerospace list-windows --monitor all --format '%{window-id}|%{app-name}' 2>/dev/null |
      awk -F'|' -v name="$target" '$2 == name { print $1 }' || true)
  fi
  if [[ -n $ids ]]; then
    workspace=$(aerospace list-workspaces --focused)
    while IFS= read -r id; do
      aerospace move-node-to-workspace --window-id "$id" "$workspace"
    done <<<"$ids"
    aerospace focus --window-id "$(head -1 <<<"$ids")"
    exit 0
  fi
fi

if ! open "${flags[@]}" "$@" 2>/dev/null; then
  osascript -e "display notification \"Could not launch $target\" with title \"AeroSpace\""
  exit 1
fi
