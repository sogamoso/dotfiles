#!/usr/bin/env bash
set -euo pipefail

# Opens the focused pane's pull request. Run detached by prefix+shift+u and
# prefix+shift+b (type = "shell" in the herdr config). By default it goes to
# terminal-browser, in a pane split off the focused one, which closes with it
# (Ctrl+Q). With --browser, or without terminal-browser installed, it goes to
# the default browser, where GitHub has a session, a tab per pull request when
# the branch has several (one per base).
#
# terminal-browser draws in the herdr pane it's started in, so the script makes
# that pane itself. A popup has no pane, and herdr's temporary command pane is
# zoomed, which a Kitty graphics pane paints blank on macOS with Ghostty, as
# does a frame the size of a whole tab (herdr#3877). So the tab is unzoomed
# first, the split takes half, and terminal-browser gets the newest pull
# request only. ~/.local/bin is checked by name because Omarchy's install
# links it there, and that may not be on herdr's PATH.

herdr="${HERDR_BIN_PATH:-herdr}"
cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
pane="${HERDR_ACTIVE_PANE_ID:-}"
browser=$(command -v terminal-browser || echo "$HOME/.local/bin/terminal-browser")
[[ ${1:-} == "--browser" || -z $pane ]] && browser=""

# Only pull request URLs, since one gets typed into a pane's shell below
branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
urls=()
if [[ -n $branch ]]; then
  while IFS= read -r url; do
    [[ $url =~ ^https://[A-Za-z0-9.-]+/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/pull/[0-9]+$ ]] && urls+=("$url")
  done < <(cd "$cwd" && gh pr list --head "$branch" --state open --json url --jq '.[].url' 2>/dev/null)
fi

if (( ${#urls[@]} == 0 )); then
  "$herdr" notification show "No pull request for this branch" >/dev/null 2>&1 || true
  exit 0
fi

if [[ -x $browser ]]; then
  "$herdr" pane zoom --off --pane "$pane" >/dev/null 2>&1 || true
  new=$("$herdr" pane split --pane "$pane" --direction right --ratio 0.5 --cwd "$cwd" | jq -r '.result.pane.pane_id')
  printf -v command 'exec %q open %q' "$browser" "${urls[0]}"
  "$herdr" pane run "$new" "$command" >/dev/null
  exit 0
fi

for url in "${urls[@]}"; do
  case "$(uname -s)" in
    Darwin) open "$url" ;;
    *) xdg-open "$url" >/dev/null 2>&1 ;;
  esac
done
