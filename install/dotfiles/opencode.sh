#!/usr/bin/env bash
set -euo pipefail

# OpenCode's config holds secrets (MCP authorization headers), so it can't be
# stowed. Merge in the settings Omarchy ships in config/opencode instead.
# OpenCode 2 reads its theme from cli.json, not opencode.json, and spells the
# update policy `update: "disable"`; the 1.x keys it ignores are dropped. As
# Omarchy's migration does, a theme already picked in cli.json is left alone,
# and a missing cli.json is left to OpenCode's own migration while it has an
# older tui.json or kv.json to carry over. Both files follow the terminal's
# Tokyo Night palette through the system theme, and updates stay with mise,
# which installs OpenCode and upgrades it with the other agents.
dir="$HOME/.config/opencode"
config="$dir/opencode.json"
cli="$dir/cli.json"

mkdir -p "$dir"
[[ -s $config ]] || echo '{ "$schema": "https://opencode.ai/config.json" }' >"$config"

if ! jq -e '.update == "disable" and (has("theme") or has("autoupdate") | not)' "$config" >/dev/null; then
  tmp=$(mktemp)
  jq '.update = "disable" | del(.theme, .autoupdate)' "$config" >"$tmp"
  cat "$tmp" >"$config"
  rm -f "$tmp"
fi

if [[ -f $cli ]]; then
  if ! jq -e 'has("theme")' "$cli" >/dev/null; then
    tmp=$(mktemp)
    jq '.theme = {name: "system"}' "$cli" >"$tmp"
    cat "$tmp" >"$cli"
    rm -f "$tmp"
  fi
elif [[ ! -e $dir/tui.json && ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/opencode/kv.json ]]; then
  cat >"$cli" <<'JSON'
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": {
    "name": "system"
  }
}
JSON
  chmod 600 "$cli"
fi
