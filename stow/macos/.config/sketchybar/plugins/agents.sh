#!/usr/bin/env bash
# Agent usage limits, after Omarchy's agents widget. The bar holds the icon
# alone, turning red once any agent's limit reaches 90%. A click opens a popup
# with each agent's plan, limits and time until they reset; a right click
# starts Claude Code in ~/Work with auto-approval, as Omarchy launches agents
# (the same flag `dotfiles agent run` uses), and a middle click checks again.
#
# Each refresh caches the last good numbers per agent, so a refused or failed
# check shows them as stale with the reason instead of blanking the item.

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/common.sh"
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/colors.sh"
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/agents.sh"

CACHE="${TMPDIR:-/tmp}/dotfiles-agents"
# Alphabetical, as Omarchy orders them
AGENTS=("claude|Claude Code" "codex|Codex" "cursor|Cursor" "grok|Grok")
ROWS=4
ALARM=90

# $1 is the minimum seconds between checks: the routine poll and a click can
# land together, and Anthropic rate-limits its usage endpoint readily
refresh() {
  local entry id record
  debounce agents-refresh "$1" || return 0
  mkdir -p "$CACHE"
  for entry in "${AGENTS[@]}"; do
    id=${entry%%|*}
    (
      record=$("agents_$id")
      if [[ -z $record ]]; then
        rm -f "$CACHE/$id.json"
      elif [[ "$(jq -r '.limits == null' <<<"$record")" == "false" ]]; then
        jq -c --argjson at "$(date +%s)" '. + {fetched: $at}' <<<"$record" >"$CACHE/$id.json"
      elif [[ -f $CACHE/$id.json ]]; then
        jq -c --argjson new "$record" '. + {status: $new.status}' "$CACHE/$id.json" >"$CACHE/$id.tmp" &&
          mv "$CACHE/$id.tmp" "$CACHE/$id.json"
      else
        jq -c '. + {limits: [], fetched: null}' <<<"$record" >"$CACHE/$id.json"
      fi
    ) &
  done
  wait
}

# Time until a reset, the way Omarchy writes it: 2d 3h, 19h 40m, 5m
until_reset() {
  local left=$(( $1 - $(date +%s) ))
  (( left < 60 )) && left=60
  if (( left >= 86400 )); then
    echo "$(( left / 86400 ))d $(( left % 86400 / 3600 ))h"
  elif (( left >= 3600 )); then
    echo "$(( left / 3600 ))h $(( left % 3600 / 60 ))m"
  else
    echo "$(( left / 60 ))m"
  fi
}

meter() {
  local filled=$(( ($1 + 5) / 10 )) out="" i
  for (( i = 0; i < 10; i++ )); do (( i < filled )) && out+="█" || out+="░"; done
  echo "$out"
}

render() {
  local entry id name file plan status fetched n count percent label text resets color
  local now worst=0 args=()
  now=$(date +%s)
  for entry in "${AGENTS[@]}"; do
    id=${entry%%|*}
    name=${entry#*|}
    file="$CACHE/$id.json"
    count=0

    # Omarchy leaves out an agent that isn't installed or signed in here
    if [[ ! -f $file ]]; then
      args+=(--set "agents.$id" drawing=off)
    else
      args+=(--set "agents.$id" drawing=on)
      plan=$(jq -r '.plan // ""' "$file")
      status=$(jq -r '.status // ""' "$file")
      fetched=$(jq -r '.fetched // empty' "$file")
      if [[ -n $status ]]; then
        label="$status${fetched:+ · as of $(date -r "$fetched" +%H:%M)}"
        args+=(--set "agents.$id" icon="$name" label="$label" label.color=$RED)
      else
        args+=(--set "agents.$id" icon="$name" label="$plan" label.color=$MUTED)
      fi
      count=$(jq '.limits | length' "$file")
      for (( n = 0; n < count && n < ROWS; n++ )); do
        label=$(jq -r ".limits[$n].label" "$file")
        text=$(jq -r ".limits[$n].text // empty" "$file")
        resets=$(jq -r ".limits[$n].resets // empty" "$file")
        if [[ -n $text ]]; then
          args+=(--set "agents.$id.$((n + 1))" drawing=on icon="$label" label.color=$TEXT
            label="$text${resets:+ · expire in $(until_reset "$resets")}")
          continue
        fi
        percent=$(jq -r ".limits[$n].percent | round" "$file")
        # A window whose reset has passed starts again from nothing
        [[ -n $resets ]] && (( resets <= now )) && percent=0
        (( percent >= ALARM )) && color=$RED || color=$TEXT
        args+=(--set "agents.$id.$((n + 1))" drawing=on icon="$label" label.color="$color"
          label="$(meter "$percent") $(printf '%3s' "$percent")%${resets:+  $(until_reset "$resets")}")
        (( percent > worst )) && worst=$percent
      done
    fi
    for (( n = count; n < ROWS; n++ )); do
      args+=(--set "agents.$id.$((n + 1))" drawing=off)
    done
  done

  (( worst >= ALARM )) && color=$RED || color=$TEXT
  args+=(--set "$NAME" icon.color="$color")
  sketchybar "${args[@]}"
}

case "${SENDER:-}" in
  mouse.clicked)
    case "${BUTTON:-}" in
      right)
        "$HOME/.config/aerospace/launch-or-focus.sh" --new Ghostty --args --working-directory="$HOME/Work" -e claude --permission-mode auto
        ;;
      other)
        refresh 15
        render
        ;;
      *)
        render
        sketchybar --set "$NAME" popup.drawing=toggle
        # Opening the popup is when fresh numbers matter, as in Omarchy
        { refresh 300 && render; } &
        ;;
    esac
    ;;
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  *)
    render
    refresh 300
    render
    ;;
esac
