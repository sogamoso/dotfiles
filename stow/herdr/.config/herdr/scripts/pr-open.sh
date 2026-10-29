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
# zoomed, which a Kitty graphics pane paints blank on macOS with Ghostty
# (herdr#3877). So the tab is unzoomed first and the browser gets half a pane.
# herdr hands frames to the terminal through files only up to 16 MiB each and
# pushes bigger ones through the pty as text, which lags, so the second stage
# (--pane, run inside the new pane) measures the pane in pixels and narrows it
# until a frame fits, by widening the pane it was split from: herdr's resize
# moves the divider on the named pane's side. DOTFILES_PR_OPEN_FRAME_LIMIT
# overrides the limit, for testing. ~/.local/bin is checked by name because Omarchy's install links
# terminal-browser there, and that may not be on herdr's PATH.

herdr="${HERDR_BIN_PATH:-herdr}"
browser=$(command -v terminal-browser || echo "$HOME/.local/bin/terminal-browser")
self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/$(basename "${BASH_SOURCE[0]}")"
pr_url='^https://[A-Za-z0-9.-]+/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/pull/[0-9]+$'

# Second stage, inside the new pane: fit the frame, then become the browser
if [[ ${1:-} == "--pane" ]]; then
  url="${2:-}"
  parent="${3:-}"
  [[ $url =~ $pr_url ]] || exit 1
  limit="${DOTFILES_PR_OPEN_FRAME_LIMIT:-$((15 * 1024 * 1024))}"
  measure='import fcntl, os, struct, termios
fd = os.open("/dev/tty", os.O_RDWR)
print(*struct.unpack("HHHH", fcntl.ioctl(fd, termios.TIOCGWINSZ, b"\0" * 8))[2:])'
  # Isolated: the pane's directory is a checkout, which could shadow a module
  read -r xpx ypx < <(python3 -I -c "$measure" 2>/dev/null || echo "")
  if [[ -n ${xpx:-} && -n ${ypx:-} ]] && (( xpx * ypx * 4 > limit )); then
    # The pane holds half its split; narrow it so a frame (4 bytes a pixel) fits
    amount=$(awk -v px="$((xpx * ypx * 4))" -v limit="$limit" 'BEGIN { printf "%.3f", 0.5 * (1 - limit / px) }')
    [[ -n $parent ]] && "$herdr" pane resize --pane "$parent" --direction right --amount "$amount" >/dev/null 2>&1 || true
  fi
  exec "$browser" open "$url"
fi

cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
pane="${HERDR_ACTIVE_PANE_ID:-}"
[[ ${1:-} == "--browser" || -z $pane ]] && browser=""

# Only pull request URLs, since one gets typed into a pane's shell below
branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
urls=()
if [[ -n $branch ]]; then
  while IFS= read -r url; do
    [[ $url =~ $pr_url ]] && urls+=("$url")
  done < <(cd "$cwd" && gh pr list --head "$branch" --state open --json url --jq '.[].url' 2>/dev/null)
fi

if (( ${#urls[@]} == 0 )); then
  "$herdr" notification show "No pull request for this branch" >/dev/null 2>&1 || true
  exit 0
fi

if [[ -x $browser ]]; then
  "$herdr" pane zoom --off --pane "$pane" >/dev/null 2>&1 || true
  env=() # expanded with the ${env[@]+...} guard: bash 3.2 and set -u reject an empty array
  [[ -n ${DOTFILES_PR_OPEN_FRAME_LIMIT:-} ]] && env=(--env "DOTFILES_PR_OPEN_FRAME_LIMIT=$DOTFILES_PR_OPEN_FRAME_LIMIT")
  new=$("$herdr" pane split --pane "$pane" --direction right --ratio 0.5 --cwd "$cwd" ${env[@]+"${env[@]}"} | jq -r '.result.pane.pane_id')
  printf -v command 'exec %q --pane %q %q' "$self" "${urls[0]}" "$pane"
  "$herdr" pane run "$new" "$command" >/dev/null
  exit 0
fi

for url in "${urls[@]}"; do
  case "$(uname -s)" in
    Darwin) open "$url" ;;
    *) xdg-open "$url" >/dev/null 2>&1 ;;
  esac
done
