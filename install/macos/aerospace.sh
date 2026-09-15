#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  log_heading "Starting AeroSpace..."
  if open -a AeroSpace; then
    log_success "AeroSpace launched — grant accessibility permissions when prompted"
  else
    log_warn "Could not launch AeroSpace — start it manually, then grant accessibility permissions"
  fi
fi

log_heading "Workspaces:"
log_info " 1  Browse                   — Chrome, Safari"
log_info " 2  Dev                      — Ghostty, Zed, Conductor"
log_info " 3  Chat                     — Slack, WhatsApp, Discord"
log_info " 4  Mail & calendar          — Thunderbird"
log_info " 5  Other work apps          — Notion"
log_info " 6  Misc"
log_info " 7  Entertainment            — Spotify, Podcasts"
log_info " 8  Misc"
log_info " 9  Misc"
log_info "10  Scratchpad (Option+S)"
log_warn "Grant accessibility permissions when prompted"
