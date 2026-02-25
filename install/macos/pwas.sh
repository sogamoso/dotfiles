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

if [[ ! -d "$CHROME_APPS/Hotkeys.app" ]]; then
  echo -e "\n==> Installing Hotkeys PWA..."
  PORT=8765
  DIR="$HOME/.config/raycast/hotkeys"
  if ! lsof -ti:$PORT > /dev/null 2>&1; then
    python3 -m http.server $PORT --directory "$DIR" > /dev/null 2>&1 &
    sleep 0.3
  fi
  open -a "Google Chrome" "http://localhost:$PORT"
  echo "Opened http://localhost:$PORT — install via ⋮ → Cast, save, and share → Install page as app"
fi
