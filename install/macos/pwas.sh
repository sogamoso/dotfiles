#!/usr/bin/env bash
set -euo pipefail

missing=()
[[ ! -d "$HOME/Applications/Gmail.app" ]] && missing+=("https://mail.google.com")
[[ ! -d "$HOME/Applications/Google Calendar.app" ]] && missing+=("https://calendar.google.com")

if (( ${#missing[@]} )); then
  echo -e "\n==> Installing PWAs..."
  for url in "${missing[@]}"; do
    open -a "Google Chrome" "$url"
    echo "Opened $url — install via ⋮ → Cast, save, and share → Install page as app"
  done
fi
