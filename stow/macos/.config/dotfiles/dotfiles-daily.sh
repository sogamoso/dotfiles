#!/usr/bin/env bash
# Run `dotfiles update` then `dotfiles doctor` once a day, from the
# com.sogamoso.dotfiles-daily LaunchAgent, and say how it went in a
# notification. Clicking it opens the full log.
#
# Like brew autoupdate's --ac-only, a laptop on battery is skipped; launchd runs
# a missed day on the next wake anyway. Doctor runs even when the update fails,
# since a broken update is exactly when its checks matter, so no `set -e`.
# Nothing here can answer a password prompt, so the update runs unattended:
# Homebrew only installs new Brewfile entries and leaves upgrades to brew
# autoupdate, which can prompt in a window. A step that still needs sudo fails
# rather than waits, and the notification says to run `dotfiles brew`.
set -uo pipefail

GROUP_ID="dotfiles-daily"
source "$HOME/.config/dotfiles/lib/notify.sh"

DOTFILES="${DOTFILES:-$HOME/Work/sogamoso/dotfiles}"
[[ -d $DOTFILES ]] || DOTFILES="$HOME/Code/sogamoso/dotfiles"  # a machine not yet moved to ~/Work
CLI="$HOME/.local/bin/dotfiles"
LOG="/tmp/com.sogamoso.dotfiles-daily.log"

if pmset -g batt | grep -q "Battery Power"; then
  echo "$(date '+%F %T') on battery, skipped"
  exit 0
fi

before=$(git -C "$DOTFILES" rev-parse HEAD 2>/dev/null)
{
  echo "=== $(date '+%F %T') dotfiles update"
  DOTFILES_UNATTENDED=1 "$CLI" update
} >"$LOG" 2>&1
update=$?
after=$(git -C "$DOTFILES" rev-parse HEAD 2>/dev/null)

{
  echo
  echo "=== $(date '+%F %T') dotfiles doctor"
  "$CLI" doctor
} >>"$LOG" 2>&1
doctor=$?

pulled=0
[[ -n $before && -n $after && $before != "$after" ]] &&
  pulled=$(git -C "$DOTFILES" rev-list --count "$before..$after")
changes="No new commits"
(( pulled > 0 )) && changes="Pulled $pulled commit$( (( pulled == 1 )) || echo s)"

if (( update != 0 )); then
  notify "Dotfiles update failed" "$changes · run dotfiles brew in a terminal, or click for the log" -open "file://$LOG"
elif (( doctor != 0 )); then
  # The first ✗ line names the problem; the log has the fix next to it
  problem=$(grep -m1 "✗" "$LOG" | sed 's/^ *✗ *//')
  notify "Dotfiles doctor found problems" "${problem:-See the log} · click for the log" -open "file://$LOG"
else
  notify "Dotfiles up to date" "$changes · all doctor checks passed" -open "file://$LOG"
fi

echo "$(date '+%F %T') update=$update doctor=$doctor pulled=$pulled"
