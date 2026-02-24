#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/supplement.sh"
bash "$DIR/brew.sh"
bash "$DIR/security.sh"
bash "$DIR/defaults.sh"

MANUAL_STEPS_MARKER="$HOME/.config/omadots/.manual-steps-done"

if [[ ! -f "$MANUAL_STEPS_MARKER" ]]; then
  cat <<'EOF'

──────────────────────────────────────────────────────────────
  Additional manual steps (beyond Omamac)
──────────────────────────────────────────────────────────────

  1. Install Gmail and Google Calendar as Chrome web apps
     Open each URL in Chrome → ⋮ menu → "Cast, save, and share"
     → "Install page as app".
       • https://mail.google.com
       • https://calendar.google.com

  Once done, run to avoid seeing this message every time:
    touch ~/.config/omadots/.manual-steps-done

──────────────────────────────────────────────────────────────

EOF
fi
