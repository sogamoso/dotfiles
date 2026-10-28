#!/usr/bin/env bash
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib"
source "$LIB/log.sh"
source "$LIB/login-items.sh"

log_heading "Adding login items..."

# Runs after pwas.sh and apps.sh, which install Gmail, Google Calendar and Wabi
if ! current=$(login_item_paths 2>/dev/null); then
  log_warn "Could not read login items — grant Automation access to System Events and rerun"
  exit 0
fi

for app in "${LOGIN_ITEMS[@]}"; do
  name=$(basename "$app" .app)
  if grep -Fxq "$app" <<<"$current"; then
    continue
  elif [[ ! -d $app ]]; then
    log_warn "$name isn't installed, so it isn't a login item"
  elif osascript -e 'on run argv' \
    -e 'tell application "System Events" to make login item at end with properties {path:(item 1 of argv), hidden:false}' \
    -e 'end run' "$app" >/dev/null; then
    log_success "$name opens at login"
  else
    log_warn "Could not add $name to login items"
  fi
done
