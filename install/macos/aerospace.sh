#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  log_heading "Starting AeroSpace..."
  open -a AeroSpace
  log_success "AeroSpace launched — grant accessibility permissions when prompted"
fi

log_heading "Workspaces:"
log_info " 1  Ghostty / Zed"
log_info " 2  Chrome / Safari / Meet"
log_info " 3  Slack"
log_info " 4  Gmail"
log_info " 5  Calendar"
log_info " 6  Todoist / Notion / Linear"
log_info " 7  HEY"
log_info " 8  WhatsApp"
log_info " 9  Spotify / YouTube"
log_info "10  Scratchpad (Option+S)"
log_warn "Grant accessibility permissions when prompted"
