#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Configuring Ghostty..."

# Append Ghostty local overlay (Omamac owns base config)
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
GHOSTTY_OVERLAY='config-file = config.local'
if [[ -f "$GHOSTTY_CONFIG" ]]; then
  grep -qxF "$GHOSTTY_OVERLAY" "$GHOSTTY_CONFIG" 2>/dev/null || echo "$GHOSTTY_OVERLAY" >> "$GHOSTTY_CONFIG"
fi
