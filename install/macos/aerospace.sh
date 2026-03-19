#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  log_heading "Starting AeroSpace..."
  open -a AeroSpace
  log_success "AeroSpace launched — grant accessibility permissions when prompted"
fi

log_heading "Workspaces:"
log_item "1  Ghostty / Zed"
log_item "2  Chrome / Safari"
log_item "3  Slack"
log_item "4  Gmail"
log_item "5  Todoist / Calendar / Meet"
log_item "6  Notion / Linear / GitHub"
log_item "7  HEY"
log_item "8  WhatsApp"
log_item "9  Spotify / YouTube"
log_item "10 Scratchpad (Cmd+0)"
log_action "Grant accessibility permissions when prompted"
