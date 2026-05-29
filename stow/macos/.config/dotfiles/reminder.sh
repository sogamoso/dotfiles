#!/usr/bin/env bash
# Lightweight ephemeral reminders, ported from Omarchy's omarchy-reminder.
# Backed by backgrounded `sleep`; reminders die on logout/reboot,
# matching Omarchy's tmpfs-backed ephemeral intent.
#
# Usage:
#   reminder.sh set <minutes> [message]
#   reminder.sh show
#   reminder.sh clear
set -euo pipefail

STATE_DIR="${TMPDIR:-/tmp}/dotfiles-reminders"

notify() { osascript -e "display notification \"${2:-}\" with title \"$1\""; }

prune() {
  [[ -d $STATE_DIR ]] || return 0
  local f
  for f in "$STATE_DIR"/*.reminder; do
    [[ -e $f ]] || continue
    kill -0 "$(basename "$f" .reminder)" 2>/dev/null || rm -f "$f"
  done
}

cmd_set() {
  local minutes="${1:-}" message="${2:-}"

  [[ $minutes =~ ^[0-9]+$ ]] && (( minutes > 0 )) \
    || { notify "Reminder" "Invalid duration: ${minutes:-empty}"; exit 1; }
  [[ -z $message ]] && message="Your $minutes minutes are up"

  mkdir -p "$STATE_DIR"
  local due=$(( $(date +%s) + minutes * 60 ))
  (
    sleep_pid=
    trap 'kill $sleep_pid 2>/dev/null; rm -f "$STATE_DIR/$BASHPID.reminder"; exit 0' TERM
    sleep $(( minutes * 60 )) &
    sleep_pid=$!
    wait $sleep_pid
    osascript -e "display notification \"$message\" with title \"Reminder\" sound name \"Glass\""
    rm -f "$STATE_DIR/$BASHPID.reminder"
  ) </dev/null >/dev/null 2>&1 &
  local pid=$!
  disown "$pid"
  printf '%s|%s\n' "$due" "$message" >"$STATE_DIR/$pid.reminder"
  notify "Reminder set for $minutes min" "Reminding at $(date -r "$due" +%H:%M)"
}

cmd_show() {
  prune
  local body="" f due msg now
  now=$(date +%s)
  for f in "$STATE_DIR"/*.reminder; do
    [[ -e $f ]] || continue
    IFS='|' read -r due msg <"$f"
    (( due > now )) || continue
    body+="$msg in $(( (due - now) / 60 ))m ($(date -r "$due" +%H:%M))"$'\n'
  done
  notify "Upcoming reminders" "${body:-No outstanding reminders}"
}

cmd_clear() {
  [[ -d $STATE_DIR ]] || { notify "Reminders" "Nothing to clear"; return; }
  local f
  for f in "$STATE_DIR"/*.reminder; do
    [[ -e $f ]] || continue
    kill "$(basename "$f" .reminder)" 2>/dev/null || true
    rm -f "$f"
  done
  notify "Reminders" "All reminders cleared"
}

case "${1:-}" in
  set)   shift; cmd_set "$@" ;;
  show)  cmd_show ;;
  clear) cmd_clear ;;
  *)     echo "Usage: $0 {set <min> [msg] | show | clear}" >&2; exit 64 ;;
esac
