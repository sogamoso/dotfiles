#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# macOS prerequisite: Xcode Command Line Tools (provides git, compilers, etc.)
if ! xcode-select -p >/dev/null 2>&1; then
  log_heading "Xcode Command Line Tools not found. Launching installer..."
  xcode-select --install || true
  log_info "Please complete the install, then run bootstrap again."
  exit 1
fi
