#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

CHROME_APPS="$HOME/Applications/Chrome Apps.localized"

names=()
urls=()
[[ ! -d "$CHROME_APPS/YouTube.app" ]] && { names+=("YouTube"); urls+=("https://youtube.com"); }

if (( ${#urls[@]} )); then
  log_heading "Installing PWAs..."
  open -a "Google Chrome" "${urls[@]}" "chrome://apps/"
  for i in "${!names[@]}"; do
    log_item "${names[$i]} (${urls[$i]})"
  done
  log_info "Install each via ⋮ → Cast, save, and share → Install page as app"
  log_info "Then in the chrome://apps/ tab, right-click each PWA and set:"
  log_item "☑ Open as window"
  for name in "${names[@]}"; do
    log_item "Opening supported links → Open in $name"
  done
fi
