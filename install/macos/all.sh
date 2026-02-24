#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/omadots.sh"
bash "$DIR/brew.sh"
bash "$DIR/security.sh"
bash "$DIR/defaults.sh"

MANUAL_STEPS_MARKER="$HOME/.config/omadots/.manual-steps-done"

if [[ ! -f "$MANUAL_STEPS_MARKER" ]]; then
  cat <<'EOF'

──────────────────────────────────────────────────────────────
  Manual post-setup steps
──────────────────────────────────────────────────────────────

  1. Create nine workspaces
     Open Mission Control (F3 or swipe up with three fingers).
     Hover over the top-right of the Spaces bar and click the
     "+" button until you have nine workspaces.

  2. Disable default Mission Control & Spotlight shortcuts
     System Settings → Keyboard → Keyboard Shortcuts →
       • Mission Control: uncheck all shortcuts
       • Spotlight: uncheck all shortcuts

  3. Enable ⌘1–⌘9 to switch workspaces
     System Settings → Keyboard → Keyboard Shortcuts →
       • Mission Control: scroll down to "Switch to Desktop 1"
         through "Switch to Desktop 9". Enable each one and
         assign ⌘1 through ⌘9 respectively.

  4. Install Gmail and Google Calendar as Chrome web apps
     Open each URL in Chrome → ⋮ menu → "Cast, save, and share"
     → "Install page as app".
       • https://mail.google.com
       • https://calendar.google.com

  5. Authenticate GitHub CLI
     Run: gh auth login
     Choose SSH, authenticate via browser.

  6. Log out and back in
     Apple menu → Log Out (⌘+⇧+Q) to apply all changes.

  Once done, run to avoid seeing this message every time:
    touch ~/.config/omadots/.manual-steps-done

──────────────────────────────────────────────────────────────

EOF
fi
