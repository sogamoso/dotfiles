#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Ghostty as the default terminal, where Omarchy 4 ships foot. Through Omarchy's
# own command, which installs Ghostty and its Omarchy config when missing and
# writes ~/.config/xdg-terminals.list: the per-user list xdg-terminal-exec reads
# ahead of the system one, for Super + Return and every other terminal launch.

log_heading "Setting Ghostty as the default terminal..."

if ! command -v omarchy-default-terminal >/dev/null; then
  log_warn "omarchy-default-terminal not found; is this Omarchy?"
  exit 0
fi

if [[ $(omarchy-default-terminal) == "ghostty" ]]; then
  log_item "Ghostty (already the default)"
else
  omarchy-default-terminal --install ghostty
fi

log_success "Ghostty is the default terminal"
