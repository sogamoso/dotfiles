
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "\n==> Configuring Hammerspoon..."

# Append hotkeys module to Hammerspoon config (Omamac owns init.lua)
HS_INIT="$HOME/.config/hammerspoon/init.lua"
HS_OVERLAY='require("hotkeys")'
grep -qxF "$HS_OVERLAY" "$HS_INIT" 2>/dev/null || echo "$HS_OVERLAY" >> "$HS_INIT"
