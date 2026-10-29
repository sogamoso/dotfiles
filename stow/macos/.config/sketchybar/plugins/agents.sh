#!/usr/bin/env bash
# Agent usage, after Omarchy's agents panel, drawn from the records Omarchy's
# own collectors print (see lib/agents.sh). The bar holds the icon alone,
# turning red once any agent's limit reaches 90%. A click opens a popup with
# what today's and the week's tokens add up to, then each agent's plan,
# limits, balance and time until they reset; a right click starts Claude Code
# in ~/Work with auto-approval, as Omarchy launches agents (the same flag
# `dotfiles agent run` uses), and a middle click checks again, forced, as
# Omarchy's refresh button does.
#
# A collector that fails leaves the agent's last record on show; one that
# keeps its last limits past a failed check says so in the record, and the
# popup shows them with the time they were measured.

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/common.sh"
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/colors.sh"
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/agents.sh"

CACHE="${TMPDIR:-/tmp}/dotfiles-agents"
ROWS=5
ALARM=90

# $1 is the minimum seconds between checks: the routine poll and a click can
# land together, and the usage endpoints rate-limit readily. $2 is --force.
refresh() {
  local id
  debounce agents-refresh "$1" || return 0
  mkdir -p "$CACHE"
  # Collectors forced together read the Codex rollouts they share once by
  # knowing when the refresh began, as Omarchy's updater tells them
  OMARCHY_AGENT_USAGE_REFRESH_AT=$(date +%s)
  export OMARCHY_AGENT_USAGE_REFRESH_AT
  for id in $(agents_ids); do
    agents_collect "$CACHE" "$id" ${2:+"$2"} &
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

# Token counts the way Omarchy's hero line writes them: 1.2M, 340k
tokens() {
  local n=$1
  if (( n >= 1000000000 )); then echo "$(( n / 1000000000 )).$(( n % 1000000000 / 100000000 ))B"
  elif (( n >= 1000000 )); then echo "$(( n / 1000000 )).$(( n % 1000000 / 100000 ))M"
  elif (( n >= 1000 )); then echo "$(( n / 1000 ))k"
  else echo "$n"; fi
}

render() {
  local id file name plan status stale fetched asof n count label percent resets color
  local now worst=0 args=() files=()
  now=$(date +%s)

  # What the records' token counts add up to, the figures Omarchy's hero
  # line rotates through
  for file in "$CACHE"/*.json; do [[ -f $file ]] && files+=("$file"); done
  local today prompts sessions week model
  IFS=$'\t' read -r today prompts sessions week model < <(jq -s -r '
    [(map(.todayTotalTokens // 0) | add), (map(.todayPrompts // 0) | add),
     (map(.todaySessions // 0) | add), (map(.recentDays[]? | .messageCount // 0) | add),
     (map(.todayTokensByModel // {} | to_entries[]) | group_by(.key)
      | map({key: .[0].key, tokens: (map(.value) | add)}) | max_by(.tokens) | .key // "")]
    | @tsv' "${files[@]}" /dev/null 2>/dev/null)
  if (( ${today:-0} > 0 )); then
    args+=(--set agents.stats.1 drawing=on icon="Today" label="$(tokens "$today") tokens · $prompts prompts · $sessions sessions")
    args+=(--set agents.stats.2 drawing=on icon="This week" label="$(tokens "${week:-0}") tokens${model:+ · top model $model}")
  else
    args+=(--set agents.stats.1 drawing=off --set agents.stats.2 drawing=off)
  fi

  for id in $(agents_ids); do
    file="$CACHE/$id.json"
    count=0

    # An agent that isn't used or signed in here has no record, as in Omarchy.
    # A record from before the widget read Omarchy's shape is none either.
    if [[ ! -f $file ]] || ! jq -e '.schemaVersion' "$file" >/dev/null 2>&1; then
      args+=(--set "agents.$id" drawing=off)
    else
      args+=(--set "agents.$id" drawing=on)
      name=$(jq -r '.name // .id' "$file")
      plan=$(jq -r '.tierLabel // ""' "$file")
      status=$(jq -r '.usageStatusText // ""' "$file")
      stale=$(jq -r '.limitsStale == true' "$file")
      fetched=$(jq -r '(.limitsFetchedAt // 0) / 1000 | floor' "$file")
      asof=""
      (( fetched > 0 )) && asof=" · as of $(date -r "$fetched" +%H:%M)"
      if [[ -n $status ]]; then
        args+=(--set "agents.$id" icon="$name" label="$status$asof" label.color=$RED)
      elif [[ $stale == true ]]; then
        args+=(--set "agents.$id" icon="$name" label="$plan$asof" label.color=$MUTED)
      else
        args+=(--set "agents.$id" icon="$name" label="$plan" label.color=$MUTED)
      fi

      # Each limit's meter, then the balance of a prepaid account
      while IFS=$'\t' read -r label percent resets; do
        (( count >= ROWS )) && break
        # A window whose reset has passed starts again from nothing
        [[ -n $resets ]] && (( resets <= now )) && percent=0
        (( percent >= ALARM )) && color=$RED || color=$TEXT
        args+=(--set "agents.$id.$((count + 1))" drawing=on icon="$label" label.color="$color"
          label="$(meter "$percent") $(printf '%3s' "$percent")%${resets:+  $(until_reset "$resets")}")
        (( percent > worst )) && worst=$percent
        count=$((count + 1))
      done < <(jq -r '
        def epoch: if . == null or . == "" then "" else
          sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | (try fromdateiso8601 catch "") end;
        (.limits[]? | [.label, ((.percent // 0) * 100 | round), (.resetsAt | epoch)]),
        (.balance | select(. != null and (.funded // 0) > 0)
          | ["Balance \(.remaining // 0 | . * 100 | round / 100) of \(.funded) \(.currency // "")\(if .estimated then " (est.)" else "" end)",
             ((.spent // 0) * 100 / .funded | round), ""])
        | @tsv' "$file" 2>/dev/null)
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
        refresh 15 --force
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
