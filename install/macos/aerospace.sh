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
log_info " 1    Browse            — Chrome"
log_info " 2    Dev               — Ghostty"
log_info " 3    Chat              — Slack, WhatsApp, Discord"
log_info " 4    Mail & calendar   — Gmail, Google Calendar"
log_info " 5    AI                — Claude, ChatGPT, Grok, Wabi"
log_info " 6    Basecamp          — Basecamp"
log_info " 7–9  Misc              — Anything"
log_info "10    Scratchpad        — Temporary windows (Option+S)"
log_warn "Grant accessibility permissions when prompted"
