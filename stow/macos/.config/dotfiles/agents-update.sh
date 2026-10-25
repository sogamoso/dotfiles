#!/usr/bin/env bash
# Upgrade the coding agents in ~/.config/mise/conf.d/agents.toml that have been
# installed, every four hours from the com.sogamoso.agents-update LaunchAgent.
# It stands in for Omarchy's auto_update = "4h", which on mise 2026.10.19 breaks
# how the shims call the agents. Agents never run stay uninstalled. Only a
# failure raises a notification, which opens the log.
set -uo pipefail

GROUP_ID="dotfiles-agents-update"
source "$HOME/.config/dotfiles/lib/notify.sh"

CONF="$HOME/.config/mise/conf.d/agents.toml"
LOG="/tmp/com.sogamoso.agents-update.log"

tools=()
while IFS= read -r tool; do
  tools+=("$tool")
done < <(mise ls --installed --json 2>/dev/null |
  jq -r --arg conf "$CONF" 'to_entries[] | select(any(.value[]; .source.path == $conf)) | .key')

(( ${#tools[@]} )) || exit 0

{
  echo "=== $(date '+%F %T') mise upgrade ${tools[*]}"
  mise upgrade --yes "${tools[@]}"
} >>"$LOG" 2>&1 || notify "Agent updates failed" "Click for the log" -open "file://$LOG"
