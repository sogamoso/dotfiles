#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Starting Tailscale daemon..."
brew services start tailscale
timeout 10 tailscale up --ssh || true

if timeout 5 tailscale status &>/dev/null; then
  log_success "Tailscale connected"
else
  log_warn "Tailscale is not connected. Run: tailscale up --ssh"
fi
