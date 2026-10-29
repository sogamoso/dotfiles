#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# herdr runs as a login-persistent background service (idempotent if already
# started), except on the Mac mini, whose own LaunchAgent preferences.sh loads
# (see HERDR_LAUNCHD_ISSUE). Telling the mini
# apart takes its Tailscale name, so this waits for Tailscale to be signed in;
# signed out, the service is left for dotfiles doctor to flag.
start_herdr_service() {
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/herdr-plugins.sh"
  on_herdr_machine_host && return 0
  brew services start herdr || log_warn "Could not start the herdr service. Run: brew services start herdr"
}

log_heading "Starting Tailscale daemon..."
sudo brew services start tailscale || true

# Already signed in: only make sure Tailscale SSH is on. `tailscale up` would
# refuse to run without restating every non-default flag already set.
if [[ "$(tailscale status --json 2>/dev/null | jq -r .BackendState)" == "Running" ]]; then
  tailscale set --ssh
  log_success "Tailscale connected, SSH enabled"
  start_herdr_service
  exit 0
fi

# Signing in means approving a link in the browser, which takes longer than a
# few seconds; a short timeout used to leave new machines signed out.
log_item "Sign in with sebastian@sogamo.so when the browser opens"
if tailscale up --ssh --timeout=5m; then
  log_success "Tailscale connected, SSH enabled"
  start_herdr_service
else
  log_warn "Tailscale is not connected. Run: tailscale up --ssh"
fi
