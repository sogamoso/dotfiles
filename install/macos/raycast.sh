#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Launching Raycast..."
if pgrep -f "Raycast" >/dev/null; then
  log_success "Raycast already running"
else
  open -a Raycast || log_warn "Could not launch Raycast — open it manually"
  log_warn "Once Raycast is open:"
  log_item "Complete the setup wizard"
  log_item "Set hotkey to Option+Space"
fi
