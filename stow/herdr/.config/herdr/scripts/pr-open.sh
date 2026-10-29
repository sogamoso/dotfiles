#!/usr/bin/env bash
set -euo pipefail

# Opens the focused pane's pull request. In terminal-browser by default, in the
# temporary pane prefix+shift+u runs it in, which closes with it (Ctrl+Q);
# terminal-browser takes over the herdr pane it's started in, so this can't be
# a popup, which isn't one. With --browser (prefix+shift+b),
# or without terminal-browser installed, the default browser opens it instead,
# where GitHub has a session. A branch with several open pull requests gets a
# tab for each in the browser, newest first as in the sidebar, and only the
# newest in terminal-browser, which has the one popup. ~/.local/bin is checked
# by name because Omarchy's install links it there, and that may not be on
# herdr's PATH.

# Its usage telemetry stays off, as the shells' supplement also sets
export TERMINAL_BROWSER_NO_TELEMETRY=1

cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
browser=$(command -v terminal-browser || echo "$HOME/.local/bin/terminal-browser")
[[ ${1:-} == "--browser" ]] && browser=""

branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
urls=()
if [[ -n $branch ]]; then
  while IFS= read -r url; do
    [[ -n $url ]] && urls+=("$url")
  done < <(cd "$cwd" && gh pr list --head "$branch" --state open --json url --jq '.[].url' 2>/dev/null)
fi

if (( ${#urls[@]} == 0 )); then
  echo "No pull request for this branch. Press a key to close."
  read -rsn1
  exit 0
fi

if [[ -x $browser ]]; then
  exec "$browser" open "${urls[0]}"
fi

for url in "${urls[@]}"; do
  case "$(uname -s)" in
    Darwin) open "$url" ;;
    *) xdg-open "$url" >/dev/null 2>&1 ;;
  esac
done
