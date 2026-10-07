#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Starting Tailscale daemon..."
sudo brew services start tailscale || true

# Already signed in: only make sure Tailscale SSH is on. `tailscale up` would
# refuse to run without restating every non-default flag already set.
if [[ "$(tailscale status --json 2>/dev/null | jq -r .BackendState)" == "Running" ]]; then
  tailscale set --ssh
  log_success "Tailscale connected, SSH enabled"
  exit 0
fi

# Signing in means approving a link in the browser, which takes longer than a
# few seconds; a short timeout used to leave new machines signed out.
log_item "Sign in with sebastian@sogamo.so when the browser opens"
if tailscale up --ssh --timeout=5m; then
  log_success "Tailscale connected, SSH enabled"
else
  log_warn "Tailscale is not connected. Run: tailscale up --ssh"
fi
