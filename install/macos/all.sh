#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Omamac if not already present (Rectangle Pro is a reliable Omamac signal)
if ! brew list --cask rectangle-pro &>/dev/null 2>&1; then
  curl -fsSL https://omamac.org/install | bash
fi

bash "$DIR/brew.sh"
bash "$DIR/security.sh"
bash "$DIR/preferences.sh"

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
