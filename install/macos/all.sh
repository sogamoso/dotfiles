#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/omadots.sh"
bash "$DIR/setup.sh"

cat <<'EOF'

──────────────────────────────────────────
  Manual post-setup steps
──────────────────────────────────────────
  1. Create nine default workspaces (F3 → + button)
  2. Disable Keyboard Shortcuts for Mission Control + Spotlight
     (System Settings → Keyboard → Keyboard Shortcuts)
  3. Enable "Switch to Desktop" shortcuts on ⌘1–⌘9
  4. Import Raycast config from ~/.config/raycast/Raycast.rayconfig (pw: 12345678)
  5. gh auth login
  6. Log out and back in (⌘⇧Q)
──────────────────────────────────────────

EOF
