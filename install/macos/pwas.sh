#!/usr/bin/env bash
set -euo pipefail

CHROME_APPS="$HOME/Applications/Chrome Apps.localized"

missing=()
[[ ! -d "$CHROME_APPS/Gmail.app" ]] && missing+=("https://mail.google.com")
[[ ! -d "$CHROME_APPS/Google Calendar.app" ]] && missing+=("https://calendar.google.com")
[[ ! -d "$CHROME_APPS/Google Meet.app" ]] && missing+=("https://meet.google.com")
[[ ! -d "$CHROME_APPS/YouTube.app" ]] && missing+=("https://youtube.com")

if (( ${#missing[@]} )); then
  echo -e "\n==> Installing PWAs..."
  for url in "${missing[@]}"; do
    open -a "Google Chrome" "$url"
    echo "Opened $url — install via ⋮ → Cast, save, and share → Install page as app"
  done
fi
