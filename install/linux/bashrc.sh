#!/usr/bin/env bash
set -euo pipefail

# Append personal supplement to .bashrc, in the slot Omarchy's own bashrc
# reserves for "your own exports, aliases, and functions".
OVERLAY='source $HOME/.config/bash/supplement.bash'
grep -qxF "$OVERLAY" "$HOME/.bashrc" 2>/dev/null || echo "$OVERLAY" >>"$HOME/.bashrc"
