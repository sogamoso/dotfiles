#!/usr/bin/env bash
# Launch an app, or focus it if already running.
#
# Usage:
#   launch-or-focus.sh [--new] <bundle_id_or_app_name> [open-args...]
#
# Targets containing a dot are treated as bundle IDs (open -b);
# otherwise they're treated as app names (open -a).
# --new forces a new instance (open -n).
#
# Anything after the target is passed through to `open` verbatim
# (e.g. `--args -e tmux new-session -A -s main`).
set -euo pipefail

new=false
if [[ "${1:-}" == "--new" ]]; then
  new=true
  shift
fi

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [--new] <bundle_id_or_app_name> [open-args...]" >&2
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

if ! open "${flags[@]}" "$@" 2>/dev/null; then
  osascript -e "display notification \"Could not launch $target\" with title \"AeroSpace\""
  exit 1
fi
