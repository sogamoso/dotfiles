#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# The desktop app runs its own backend only while the app is open. `hermes
# gateway install` registers a launch agent that outlives it — that's the
# messaging daemon (Telegram, Discord, Slack), which this setup doesn't use.
shopt -s nullglob
plists=("$HOME/Library/LaunchAgents"/ai.hermes.gateway*.plist)
shopt -u nullglob

if (( ${#plists[@]} )); then
  log_heading "Removing Hermes gateway launch agents..."
  for plist in "${plists[@]}"; do
    label="$(basename "$plist" .plist)"
    launchctl bootout "gui/$UID/$label" 2>/dev/null ||
      launchctl bootout "user/$UID/$label" 2>/dev/null ||
      log_warn "Could not unload $label — removing its plist anyway"
    rm -f "$plist"
    log_item "$label"
  done
  log_info "Hermes now runs only while the desktop app is open"
fi
