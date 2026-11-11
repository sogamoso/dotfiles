#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Which agents the agents widget shows is one list for every host:
# ~/.config/agents/widget.json, stowed from the agents package, in the shape of
# the providers setting in Omarchy's shell.json. The macOS widget reads it
# where it is. On Omarchy the panel reads shell.json, so the list is merged
# into the panel's providers through Omarchy's own `omarchy bar set`, keeping
# any agent the list doesn't name as it was, and written only when it changes.
config="$HOME/.config/agents/widget.json"

[[ $(uname -s) == "Linux" ]] || exit 0
[[ -f $config ]] || exit 0

log_heading "Setting which agents Omarchy's agents panel shows..."

if ! command -v omarchy >/dev/null 2>&1; then
  log_warn "omarchy isn't on PATH; the agents panel keeps its own settings"
  exit 0
fi

wanted=$(jq -c '.providers // {}' "$config")
current=$(omarchy bar get omarchy.agents providers 2>/dev/null |
  jq -c 'if type == "object" then . else {} end' 2>/dev/null || true)
current=${current:-"{}"}
merged=$(jq -cn --argjson current "$current" --argjson wanted "$wanted" '$current * $wanted')

if [[ $(jq -S . <<<"$merged") == $(jq -S . <<<"$current") ]]; then
  log_item "Omarchy's agents panel already shows the agents in widget.json"
elif omarchy bar set omarchy.agents providers "$merged" --json >/dev/null; then
  log_success "Omarchy's agents panel hides the agents widget.json turns off"
else
  log_warn "Could not update the agents panel; run: omarchy bar set omarchy.agents providers '$merged' --json"
fi
