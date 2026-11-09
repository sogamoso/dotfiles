#!/usr/bin/env bash
set -euo pipefail

# OpenCode's config holds secrets (MCP authorization headers), so it can't be
# stowed. Merge in the two settings Omarchy ships in config/opencode instead:
# follow the terminal's Tokyo Night palette, and leave updates to mise, which
# installs OpenCode and upgrades it with the other agents. OpenCode 2 reads the
# theme from cli.json and the update policy as `update`; opencode.json keeps the
# 1.x keys too, for hosts not yet upgraded.
config="$HOME/.config/opencode/opencode.json"

mkdir -p "$(dirname "$config")"
[[ -s $config ]] || echo '{ "$schema": "https://opencode.ai/config.json" }' >"$config"

if ! jq -e '.theme == "system" and .autoupdate == false and .update == "disable"' "$config" >/dev/null; then
  tmp=$(mktemp)
  jq '.theme = "system" | .autoupdate = false | .update = "disable"' "$config" >"$tmp"
  cat "$tmp" >"$config"
  rm -f "$tmp"
fi

# A theme the user picked is left alone, as is a missing file next to an older
# tui.json or kv.json, which OpenCode's own migration carries over.
cli="$HOME/.config/opencode/cli.json"
if [[ -f $cli ]]; then
  if tmp=$(jq 'if has("theme") then empty else .theme = {name: "system"} end' "$cli" 2>/dev/null) && [[ -n $tmp ]]; then
    printf '%s\n' "$tmp" >"$cli.tmp"
    chmod 600 "$cli.tmp"
    mv "$cli.tmp" "$cli"
  fi
elif [[ ! -e $HOME/.config/opencode/tui.json && ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/opencode/kv.json ]]; then
  printf '%s\n' '{ "$schema": "https://opencode.ai/v2/cli.json", "theme": { "name": "system" } }' >"$cli"
  chmod 600 "$cli"
fi
