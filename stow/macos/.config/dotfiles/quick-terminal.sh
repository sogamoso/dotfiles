#!/usr/bin/env bash
# Toggle Ghostty's quick terminal, its drop-down console, as Omarchy's
# SUPER+grave toggles its Quake console. A console opened fresh starts the
# default agent in ~/Work, as Omarchy seeds its own with omarchy-agent the first
# time it opens (default/hypr/qconsole.lua). When the agent exits the console
# goes with it, and the next toggle starts another.
#
# Bound in AeroSpace rather than as a Ghostty global keybind, which would need
# Ghostty running and Accessibility access of its own. Ghostty's AppleScript
# runs an action only on a terminal, so with none open this starts Ghostty, and
# the console drops down over its first window.
#
# Ghostty's dictionary has no name for the quick terminal, but it is the one
# terminal in no window, which is how the seed finds it. The agent is typed in
# rather than set as the console's command: toggle_quick_terminal takes no
# surface configuration, and Ghostty's `command` applies to every window. The
# leading space keeps the line out of history (HIST_IGNORE_SPACE).
set -euo pipefail

GROUP_ID="dotfiles-quick-terminal"

ghostty() {
  osascript -e "tell application \"Ghostty\"
$1
end tell" 2>/dev/null
}

toggle() {
  ghostty 'perform action "toggle_quick_terminal" on terminal 1' >/dev/null
}

# The id of the quick terminal while one is open: the terminal in no window.
# Asked only of a running Ghostty, since osascript would otherwise launch it.
console() {
  pgrep -xq ghostty || return 0
  ghostty 'set housed to {}
repeat with w in every window
  set housed to housed & (id of every terminal of w)
end repeat
repeat with t in every terminal
  if housed does not contain (id of t) then return id of t
end repeat
return ""'
}

seed() {
  ghostty "input text \" exec dotfiles agent run --pick\" to terminal id \"$1\"
send key \"enter\" to terminal id \"$1\"" >/dev/null
}

before=$(console)

shown=false
if toggle; then
  shown=true
else
  open -a Ghostty
  for _ in {1..50}; do
    if toggle; then
      shown=true
      break
    fi
    sleep 0.1
  done
fi

if [[ $shown == "false" ]]; then
  source "$HOME/.config/dotfiles/lib/notify.sh"
  notify "Ghostty" "Could not open the quick terminal"
  exit 1
fi

# With no console before the toggle, the toggle could only have opened a fresh
# one, so wait for it to appear and seed it. An existing console was shown or
# hidden and keeps whatever it was running.
[[ -z $before ]] || exit 0
fresh=""
for _ in {1..20}; do
  fresh=$(console)
  [[ -n $fresh ]] && break
  sleep 0.1
done
[[ -n $fresh ]] || exit 0

seed "$fresh"
