#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Configuring tmux..."

TMUX_CONF="$HOME/.config/tmux/tmux.conf"
LOCAL_HOOK='source-file -q ~/.config/tmux/tmux.local.conf'

if [[ -f "$TMUX_CONF" ]]; then
  grep -qxF "$LOCAL_HOOK" "$TMUX_CONF" || echo "$LOCAL_HOOK" >> "$TMUX_CONF"
  echo "✓ Local override hook wired into tmux.conf"
else
  echo "⚠ ~/.config/tmux/tmux.conf not found. Omadots may not have been installed yet"
fi
