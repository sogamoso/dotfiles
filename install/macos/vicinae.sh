#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Creates settings.json importing the stowed dotfiles.json if it's missing, and
# installs the store extensions listed in extensions.txt.
log_heading "Installing Vicinae extensions..."
if python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/vicinae.py" install; then
  log_success "Vicinae extensions installed"
else
  log_warn "Some Vicinae extensions failed to install — rerun: dotfiles vicinae reset"
fi
if ! grep -q '"dotfiles.json"' "$HOME/.config/vicinae/settings.json"; then
  log_warn "~/.config/vicinae/settings.json doesn't import dotfiles.json — run: dotfiles vicinae reset"
fi

log_heading "Launching Vicinae..."
if pgrep -x Vicinae >/dev/null; then
  log_success "Vicinae already running"
else
  open -a Vicinae || log_warn "Could not launch Vicinae — open it manually"
fi
