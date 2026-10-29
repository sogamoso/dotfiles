#!/usr/bin/env bash
set -euo pipefail

# Opens the focused pane's pull request. In terminal-browser by default, inside
# the popup prefix+shift+u runs it in, so there's only ever one open and it has
# to be closed (Ctrl+Q) before anything else. With --browser (prefix+shift+b),
# or without terminal-browser installed, the default browser opens it instead,
# where GitHub has a session. ~/.local/bin is checked by name because Omarchy's
# install links it there, and that may not be on herdr's PATH.

# Its usage telemetry stays off, as the shells' supplement also sets
export TERMINAL_BROWSER_NO_TELEMETRY=1

cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
browser=$(command -v terminal-browser || echo "$HOME/.local/bin/terminal-browser")
[[ ${1:-} == "--browser" ]] && browser=""

if ! url=$(cd "$cwd" && gh pr view --json url --jq .url 2>/dev/null); then
  echo "No pull request for this branch. Press a key to close."
  read -rsn1
  exit 0
fi

if [[ -x $browser ]]; then
  exec "$browser" open "$url"
fi

case "$(uname -s)" in
  Darwin) open "$url" ;;
  *) xdg-open "$url" >/dev/null 2>&1 ;;
esac
