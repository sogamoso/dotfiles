#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.dotfiles-bootstrapped" ]]; then
  log_heading "Starting AeroSpace..."
  open -a AeroSpace
  log_success "AeroSpace launched — grant accessibility permissions when prompted"
fi

log_heading "Workspaces:"
log_info " 1  Browse                   — Chrome, Safari"
log_info " 2  Dev                      — Ghostty, Zed, Solo, Conductor"
log_info " 3  Chat                     — Slack, WhatsApp, Discord"
log_info " 4  Work email & calendar    — Gmail, Google Calendar"
log_info " 5  Other work apps          — Notion"
log_info " 6  Personal mail & calendar — Fastmail"
log_info " 7  Entertainment            — Spotify, Podcasts"
log_info " 8  Misc"
log_info " 9  Misc"
log_info "10  Scratchpad (Option+S)"
log_warn "Grant accessibility permissions when prompted"
