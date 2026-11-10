#!/usr/bin/env bash
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib"
source "$LIB/log.sh"
source "$LIB/app-path.sh"

log_heading "Setting the PATH apps start with..."

if [[ $(app_path_current) == "$APP_PATH" ]]; then
  log_success "Apps already start with Homebrew on PATH"
  exit 0
fi

# launchd reads it only when the session starts, so running apps keep the old one
sudo launchctl config user path "$APP_PATH"
log_success "Apps start with Homebrew on PATH after the next restart"
