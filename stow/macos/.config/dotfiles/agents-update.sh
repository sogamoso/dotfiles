#!/usr/bin/env bash
# Upgrade the coding agents in ~/.config/mise/conf.d/agents.toml that have been
# installed, every four hours from the com.sogamoso.agents-update LaunchAgent.
# It stands in for Omarchy's auto_update = "4h", which on mise 2026.10.19 breaks
# how the shims call the agents. Agents never run stay uninstalled.
#
# Then it keeps plugins current, but only from sources on the allowlists below:
# my own repos, Anthropic's and Cursor's. A plugin can ship hooks and scripts
# that run on this machine, so one compromised single-maintainer repo shouldn't
# reach it unattended. Plugins from any other marketplace are held: the job
# refreshes their catalogs (a fetch, which installs and runs nothing) and
# notifies once per new version, so I can read the change and run
# `claude plugin update <id>` myself. settings.json turns Claude's own
# autoUpdate on for the same allowlist only. Failures notify and open the log.
set -uo pipefail

GROUP_ID="dotfiles-agents-update"
source "$HOME/.config/dotfiles/lib/notify.sh"

CONF="$HOME/.config/mise/conf.d/agents.toml"
LOG="/tmp/com.sogamoso.agents-update.log"
HELD_SEEN="$HOME/.local/state/dotfiles/plugins-held.txt"

# Marketplaces whose plugins update without review.
CLAUDE_TRUSTED=(claude-plugins-official cursor-plugins sendas)
CODEX_TRUSTED=(claude-plugins-official pstack-codex sendas sogamoso)

trusted() { # name, list...
  local name=$1; shift
  [[ " $* " == *" $name "* ]]
}

# The version a marketplace catalog offers for a plugin: the entry's version,
# else the plugin.json of a plugin that lives in the marketplace repo, else
# that repo's commit, which is how such plugins without a version are labelled.
catalog_version() { # marketplace, plugin name
  local dir="$HOME/.claude/plugins/marketplaces/$1" entry v src
  entry=$(jq -c --arg n "$2" '.plugins[] | select(.name == $n)' "$dir/.claude-plugin/marketplace.json" 2>/dev/null) || return
  v=$(jq -r '.version // empty' <<<"$entry")
  src=$(jq -r 'if (.source | type) == "string" then .source else empty end' <<<"$entry")
  if [[ -z $v && -n $src ]]; then
    v=$(jq -r '.version // empty' "$dir/$src/.claude-plugin/plugin.json" 2>/dev/null)
    [[ -n $v ]] || v=$(git -C "$dir" rev-parse --short=12 HEAD 2>/dev/null)
  fi
  echo "$v"
}

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
  (
    # Upgrading a Codex marketplace also updates its installed plugins, and
    # there is no fetch-only form, so only trusted ones are touched. Held
    # plugins are reported from the Claude side, which reads the same repos.
    for m in "${CODEX_TRUSTED[@]}"; do
      echo "=== $(date '+%F %T') codex plugin marketplace upgrade $m"
      codex plugin marketplace upgrade "$m" || exit 1
    done
  ) >>"$LOG" 2>&1 || failed=1
fi

held=()
rm -f "$HELD_SEEN.new"
if [[ " ${tools[*]} " == *" claude "* ]]; then
  (
    echo "=== $(date '+%F %T') claude plugin marketplace update"
    claude plugin marketplace update || exit 1
    while IFS=$'\t' read -r id installed; do
      market=${id#*@}
      if trusted "$market" "${CLAUDE_TRUSTED[@]}"; then
        claude plugin update "$id" || exit 1
      else
        offered=$(catalog_version "$market" "${id%@*}")
        if [[ -n $offered && $offered != "$installed" ]]; then
          echo "held: $id $installed -> $offered (not on the allowlist; update by hand after review)"
          echo "$id $offered" >>"$HELD_SEEN.new"
        fi
      fi
    done < <(claude plugin list --json 2>/dev/null | jq -r '.[] | select(.scope == "user") | [.id, .version] | @tsv')
  ) >>"$LOG" 2>&1 || failed=1

  # Notify once per held version, not every four hours.
  mkdir -p "$(dirname "$HELD_SEEN")"
  touch "$HELD_SEEN"
  if [[ -f "$HELD_SEEN.new" ]]; then
    while read -r id offered; do
      grep -qxF "$id $offered" "$HELD_SEEN" || held+=("$id $offered")
    done <"$HELD_SEEN.new"
    mv "$HELD_SEEN.new" "$HELD_SEEN"
  else
    : >"$HELD_SEEN"
  fi
fi

(( ${#held[@]} )) && notify "Plugin updates to review" "${held[*]}" -open "file://$LOG"
(( failed )) && notify "Agent updates failed" "Click for the log" -open "file://$LOG"
exit 0
