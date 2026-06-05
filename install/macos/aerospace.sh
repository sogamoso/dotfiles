#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  log_heading "Starting AeroSpace..."
  open -a AeroSpace
  log_success "AeroSpace launched — grant accessibility permissions when prompted"
fi

log_heading "Workspaces:"
log_info " 1  Browsing       — Chrome, Safari"
log_info " 2  Dev            — Ghostty, Zed, Solo"
log_info " 3  Chat           — Slack, WhatsApp, Discord, Telegram"
log_info " 4  Mail           — Fastmail"
log_info " 5  Work           — Notion"
log_info " 6  Entertainment  — Spotify, YouTube, Podcasts"
log_info " 7  Misc"
log_info " 8  Misc"
log_info " 9  Misc"
log_info "10  Scratchpad (Option+S)"
log_warn "Grant accessibility permissions when prompted"
