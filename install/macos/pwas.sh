#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

CHROME_APPS="$HOME/Applications/Chrome Apps.localized"

missing=()
[[ ! -d "$CHROME_APPS/Gmail.app" ]] && missing+=("https://mail.google.com")
[[ ! -d "$CHROME_APPS/Google Calendar.app" ]] && missing+=("https://calendar.google.com")
[[ ! -d "$CHROME_APPS/Google Meet.app" ]] && missing+=("https://meet.google.com")
[[ ! -d "$CHROME_APPS/YouTube.app" ]] && missing+=("https://youtube.com")
[[ ! -d "$CHROME_APPS/GitHub.app" ]] && missing+=("https://github.com")

if (( ${#missing[@]} )); then
  log_heading "Installing PWAs..."
  open -a "Google Chrome" "${missing[@]}"
  for url in "${missing[@]}"; do
    log_item "$url"
  done
  log_info "Install each via ⋮ → Cast, save, and share → Install page as app"
fi
