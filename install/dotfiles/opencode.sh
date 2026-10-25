#!/usr/bin/env bash
set -euo pipefail

# OpenCode's config holds secrets (MCP authorization headers), so it can't be
# stowed. Merge in the two settings Omarchy ships in config/opencode instead:
# follow the terminal's Tokyo Night palette, and leave updates to mise, which
# installs OpenCode and upgrades it with the other agents.
config="$HOME/.config/opencode/opencode.json"

mkdir -p "$(dirname "$config")"
[[ -s $config ]] || echo '{ "$schema": "https://opencode.ai/config.json" }' >"$config"

if ! jq -e '.theme == "system" and .autoupdate == false' "$config" >/dev/null; then
  tmp=$(mktemp)
  jq '.theme = "system" | .autoupdate = false' "$config" >"$tmp"
  cat "$tmp" >"$config"
  rm -f "$tmp"
fi
