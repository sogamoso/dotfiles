#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/omamac.sh"
bash "$DIR/brew.sh"
bash "$DIR/security.sh"
bash "$DIR/preferences.sh"

CHROME_APPS="$HOME/Applications/Chrome Apps.localized"

if [[ ! -d "$CHROME_APPS/Gmail.app" ]] || [[ ! -d "$CHROME_APPS/Google Calendar.app" ]]; then
  cat <<'EOF'

──────────────────────────────────────────────────────────────
  Additional manual steps (beyond Omamac)
──────────────────────────────────────────────────────────────

  Install Gmail and Google Calendar as Chrome web apps:
    Open each URL in Chrome → ⋮ menu → "Cast, save, and share"
    → "Install page as app".
      • https://mail.google.com
      • https://calendar.google.com

──────────────────────────────────────────────────────────────

EOF
fi
