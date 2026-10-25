# Review layouts: agent left, hunk diff watch top right, terminal bottom right.
#
# Not an Omarchy port, so unlike herdr.zsh this pair carries a bash copy. The
# bodies stay byte-identical, which keeps them to syntax both shells share:
# no arrays, and subdirectories come from find rather than a glob.

# Subdirectories of the current directory, hidden ones skipped, one per line
_layout_subdirs() {
  find "$PWD" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort
}

# Review layout in the current herdr tab
# Usage: hrl [<agent>]
hrl() {
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hrl."; return 1; }

  local current_dir="$PWD"
  local agent="${1:-cx}"
  local agent_pane="$HERDR_PANE_ID"
  local diff_pane

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  diff_pane=$(herdr pane split "$agent_pane" --direction right --ratio 0.5 --cwd "$current_dir" --no-focus |
    jq -r '.result.pane.pane_id')
  herdr pane split "$diff_pane" --direction down --ratio 0.5 --cwd "$current_dir" --no-focus >/dev/null

  herdr pane run "$diff_pane" "hunk diff --watch" >/dev/null
  herdr pane run "$agent_pane" "$agent" >/dev/null
}

# One workspace per subdirectory, each with a single hrl tab
# Usage: hrlm [<agent>]
hrlm() {
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hrlm."; return 1; }

  local agent="${1:-cx}"
  local first=true
  local hrl_command dir pane_id

  printf -v hrl_command 'hrl %q' "$agent"

  while IFS= read -r dir <&3; do
    if $first; then
      # Reuse the current workspace for the first project
      herdr workspace rename "$HERDR_WORKSPACE_ID" "$(basename "$dir")" >/dev/null
      herdr pane run "$HERDR_PANE_ID" "$(printf 'cd %q && %s' "$dir" "$hrl_command")" >/dev/null
      first=false
    else
      pane_id=$(herdr workspace create --cwd "$dir" --label "$(basename "$dir")" --no-focus |
        jq -r '.result.root_pane.pane_id')
      herdr pane run "$pane_id" "$hrl_command" >/dev/null
    fi
  done 3< <(_layout_subdirs)
}

# Review layout in the current tmux window
# Usage: trl [<agent>]
trl() {
  [[ -z $TMUX ]] && { echo "You must start tmux to use trl."; return 1; }

  local current_dir="$PWD"
  local agent="${1:-cx}"
  local agent_pane="$TMUX_PANE"
  local diff_pane

  tmux rename-window -t "$agent_pane" "$(basename "$current_dir")"

  diff_pane=$(tmux split-window -h -l 50% -d -t "$agent_pane" -c "$current_dir" -P -F '#{pane_id}')
  tmux split-window -v -l 50% -d -t "$diff_pane" -c "$current_dir"

  tmux send-keys -t "$diff_pane" "hunk diff --watch" C-m
  tmux send-keys -t "$agent_pane" "$agent" C-m
}

# One window per subdirectory in the current session, each running trl
# Usage: trlm [<agent>]
trlm() {
  [[ -z $TMUX ]] && { echo "You must start tmux to use trlm."; return 1; }

  local agent="${1:-cx}"
  local first=true
  local trl_command dir pane_id

  printf -v trl_command 'trl %q' "$agent"

  while IFS= read -r dir <&3; do
    if $first; then
      # Reuse the current window for the first project
      tmux send-keys -t "$TMUX_PANE" "$(printf 'cd %q && %s' "$dir" "$trl_command")" C-m
      first=false
    else
      pane_id=$(tmux new-window -d -c "$dir" -n "$(basename "$dir")" -P -F '#{pane_id}')
      tmux send-keys -t "$pane_id" "$trl_command" C-m
    fi
  done 3< <(_layout_subdirs)
}
