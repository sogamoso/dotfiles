#!/usr/bin/env bash
# Upgrade the coding agents in ~/.config/mise/conf.d/agents.toml that have been
# installed, every four hours from the com.sogamoso.agents-update LaunchAgent.
# It stands in for Omarchy's auto_update = "4h", which on mise 2026.10.19 breaks
# how the shims call the agents. Agents never run stay uninstalled. Then it
# refreshes the agents' plugin marketplaces, so plugins (sogamoso-skills among
# them) follow their releases without a manual upgrade: Codex has no auto-update
# setting, and Claude Code's autoUpdate in settings.json has reports of fetching
# the catalog without updating plugins. Only a failure raises a notification,
# which opens the log.
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

failed=0

if (( ${#tools[@]} )); then
  {
    echo "=== $(date '+%F %T') mise upgrade ${tools[*]}"
    mise upgrade --yes "${tools[@]}"
  } >>"$LOG" 2>&1 || failed=1
fi

# Only for agents that are installed, so a lazy one isn't installed just to
# refresh plugins it has never used.
if [[ " ${tools[*]} " == *" codex "* ]]; then
  {
    echo "=== $(date '+%F %T') codex plugin marketplace upgrade"
    codex plugin marketplace upgrade
  } >>"$LOG" 2>&1 || failed=1
fi

if [[ " ${tools[*]} " == *" claude "* ]]; then
  {
    echo "=== $(date '+%F %T') claude plugin marketplace update"
    claude plugin marketplace update
    claude plugin list --json 2>/dev/null | jq -r '.[] | select(.scope == "user") | .id' |
      while IFS= read -r plugin; do claude plugin update "$plugin" || exit 1; done
  } >>"$LOG" 2>&1 || failed=1
fi

(( failed )) && notify "Agent updates failed" "Click for the log" -open "file://$LOG"
exit 0
