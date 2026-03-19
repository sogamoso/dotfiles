#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Launching Raycast..."
if pgrep -f "Raycast" >/dev/null; then
  log_success "Raycast already running"
else
  open -a Raycast
  log_success "Raycast launched"
  log_action "Raycast setup:"
  log_item "Complete the setup wizard"
  log_item "Set hotkey to Option+Space"
fi
