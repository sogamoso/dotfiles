#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Starting Tailscale daemon..."
brew services start tailscale
tailscale up
log_success "Done"
