#!/usr/bin/env bash
# Agent usage limits, after Omarchy's agents widget. The bar shows the fullest
# current limit across agents; a click opens a popup with each agent's plan
# and limits, and a right click starts Claude Code.
#
# Each refresh caches the last good numbers per agent, so a refused or failed
# check shows them as stale with the reason instead of blanking the item.

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/common.sh"
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/colors.sh"
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/agents.sh"

CACHE="${TMPDIR:-/tmp}/dotfiles-agents"
# Cursor and Antigravity have no usage source yet; they hold their place
AGENTS=("claude|Claude Code" "codex|Codex" "cursor|Cursor" "antigravity|Antigravity")
ROWS=3

refresh() {
  local id record
  # The routine poll and a click can land together; one check is enough
  debounce agents-refresh 300 || return 0
  mkdir -p "$CACHE"
  for id in claude codex; do
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

when() {
  if (( $1 - $(date +%s) < 86400 )); then date -r "$1" +%H:%M; else date -r "$1" '+%a %H:%M'; fi
}

severity_color() {
  if (( $1 >= 95 )); then echo "$RED"; elif (( $1 >= 80 )); then echo "$YELLOW"; else echo "$TEXT"; fi
}

meter() {
  local filled=$(( ($1 + 5) / 10 )) out="" i
  for (( i = 0; i < 10; i++ )); do (( i < filled )) && out+="█" || out+="░"; done
  echo "$out"
}

render() {
  local entry id name file plan status fetched n count percent label resets worst=-1 args=()
  for entry in "${AGENTS[@]}"; do
    id=${entry%%|*}
    name=${entry#*|}
    file="$CACHE/$id.json"
    count=0

    if [[ ! -f $file ]]; then
      args+=(--set "agents.$id" icon="$name" label="no usage source yet" label.color=$MUTED)
    else
      plan=$(jq -r '.plan // ""' "$file")
      status=$(jq -r '.status // ""' "$file")
      fetched=$(jq -r '.fetched // empty' "$file")
      if [[ -n $status ]]; then
        label="$status${fetched:+ · as of $(date -r "$fetched" +%H:%M)}"
        args+=(--set "agents.$id" icon="$name" label="$label" label.color=$YELLOW)
      else
        args+=(--set "agents.$id" icon="$name" label="$plan" label.color=$MUTED)
      fi
      count=$(jq '.limits | length' "$file")
      for (( n = 0; n < count && n < ROWS; n++ )); do
        percent=$(jq -r ".limits[$n].percent | round" "$file")
        label=$(jq -r ".limits[$n].label" "$file")
        resets=$(jq -r ".limits[$n].resets // empty" "$file")
        args+=(--set "agents.$id.$((n + 1))" drawing=on icon="$label"
          label="$(meter "$percent") $(printf '%3s' "$percent")%${resets:+  resets $(when "$resets")}"
          label.color="$(severity_color "$percent")")
        (( percent > worst )) && worst=$percent
      done
    fi
    for (( n = count; n < ROWS; n++ )); do
      args+=(--set "agents.$id.$((n + 1))" drawing=off)
    done
  done

  if (( worst < 0 )); then
    args+=(--set "$NAME" drawing=off)
  else
    args+=(--set "$NAME" drawing=on label="$worst%" label.color="$(severity_color "$worst")")
  fi
  sketchybar "${args[@]}"
}

case "${SENDER:-}" in
  mouse.clicked)
    if [[ ${BUTTON:-} == "right" ]]; then
      "$HOME/.config/aerospace/launch-or-focus.sh" --new Ghostty --args -e claude
    else
      render
      sketchybar --set "$NAME" popup.drawing=toggle
      # Opening the popup is when fresh numbers matter; the debounce keeps
      # repeated opens from hammering the endpoints
      { refresh && render; } &
    fi
    ;;
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  *)
    render
    refresh
    render
    ;;
esac
