#!/usr/bin/env bash
set -euo pipefail

# Opens the focused pane's pull request in terminal-browser, inside the popup
# prefix+shift+u runs it in, so there's only ever one open and it has to be
# closed (Ctrl+Q) before anything else. Without terminal-browser installed, the
# default browser opens it instead.

cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"

if ! url=$(cd "$cwd" && gh pr view --json url --jq .url 2>/dev/null); then
  echo "No pull request for this branch. Press a key to close."
  read -rsn1
  exit 0
fi

if command -v terminal-browser >/dev/null; then
  exec terminal-browser open "$url"
fi

case "$(uname -s)" in
  Darwin) open "$url" ;;
  *) xdg-open "$url" >/dev/null 2>&1 ;;
esac
