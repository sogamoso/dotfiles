#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Launching 1Password..."
if pgrep -f "1Password" >/dev/null; then
  log_success "1Password already running"
else
  open -a "1Password"
  log_warn "1Password launched. Now:"
  log_item "Sign in to your account"
  log_item "Enable the SSH agent: Settings → Developer → Use the SSH agent"
fi
