# Herdr development layouts — ported from Omarchy's bash helpers.
#
# Two zsh differences matter in the port: arrays are 1-based rather than
# 0-based, and an unmatched glob is an error rather than a literal, so the
# subdirectory loop in hdlm needs the (N) qualifier.
#
# Omarchy runs `hunk diff --watch` in the hds diff pane; lazygit stands in here
# since that is what this machine already has.
#
# All of these build on $HERDR_PANE_ID, so they only work inside a herdr pane.

# Echo a split ratio as a float
# Usage: _herdr_ratio <numerator> <denominator>
_herdr_ratio() {
  awk -v a="$1" -v b="$2" 'BEGIN { printf "%.4f", a / b }'
}

# Split a herdr pane and echo the id of the new pane
# Usage: _herdr_split <pane_id> <right|down> <ratio> <cwd>
_herdr_split() {
  herdr pane split "$1" --direction "$2" --ratio "$3" --cwd "$4" --no-focus |
    jq -r '.result.pane.pane_id'
}

# Dev layout: editor left, agent right, terminal strip along the bottom
# Usage: hdl <agent> [<second_agent>]
hdl() {
  [[ -z $1 ]] && { echo "Usage: hdl <agent> [<second_agent>]"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hdl."; return 1; }

  local current_dir="$PWD"
  local editor_pane ai_pane ai2_pane
  local ai="$1"
  local ai2="${2:-}"

  # Use HERDR_PANE_ID for the pane we're running in (stable even if focus moves)
  editor_pane="$HERDR_PANE_ID"

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # Split tab vertically - top 85%, bottom 15%
  _herdr_split "$editor_pane" down 0.85 "$current_dir" >/dev/null

  # Split editor pane horizontally - AI on right 30%
  ai_pane=$(_herdr_split "$editor_pane" right 0.7 "$current_dir")

  # If second AI provided, split the AI pane vertically
  if [[ -n $ai2 ]]; then
    ai2_pane=$(_herdr_split "$ai_pane" down 0.5 "$current_dir")
    herdr pane run "$ai2_pane" "$ai2" >/dev/null
  fi

  herdr pane run "$ai_pane" "$ai" >/dev/null
  herdr pane run "$editor_pane" "$EDITOR ." >/dev/null
}

# Dev square: editor, diff watch, terminal, and opencode
# Usage: hds
hds() {
  [[ -n $1 ]] && { echo "Usage: hds"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hds."; return 1; }

  local current_dir="$PWD"
  local editor_pane diff_pane terminal_pane opencode_pane

  editor_pane="$HERDR_PANE_ID"

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  terminal_pane=$(_herdr_split "$editor_pane" down 0.5 "$current_dir")
  diff_pane=$(_herdr_split "$editor_pane" right 0.5 "$current_dir")
  opencode_pane=$(_herdr_split "$terminal_pane" right 0.5 "$current_dir")

  herdr pane run "$editor_pane" "$EDITOR ." >/dev/null
  herdr pane run "$diff_pane" "lazygit" >/dev/null
  herdr pane run "$opencode_pane" "opencode" >/dev/null
}

# One hdl tab per subdirectory of the current directory
# Usage: hdlm <agent> [<second_agent>]
hdlm() {
  [[ -z $1 ]] && { echo "Usage: hdlm <agent> [<second_agent>]"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hdlm."; return 1; }

  local ai="$1"
  local ai2="${2:-}"
  local base_dir="$PWD"
  local first=true
  local hdl_command

  herdr workspace rename "$HERDR_WORKSPACE_ID" "$(basename "$base_dir")" >/dev/null

  # (N) so an empty directory yields nothing instead of a glob error
  local dir
  for dir in ${base_dir}/*/(N); do
    local dirpath="${dir%/}"

    printf -v hdl_command 'hdl %q' "$ai"
    [[ -n $ai2 ]] && printf -v hdl_command '%s %q' "$hdl_command" "$ai2"

    if $first; then
      # Reuse the current tab for the first project
      printf -v hdl_command 'cd %q && %s' "$dirpath" "$hdl_command"
      herdr pane run "$HERDR_PANE_ID" "$hdl_command" >/dev/null
      first=false
    else
      local pane_id
      pane_id=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$dirpath" --no-focus |
        jq -r '.result.root_pane.pane_id')
      herdr pane run "$pane_id" "$hdl_command" >/dev/null
    fi
  done
}

# Swarm layout: tile into a grid and run the same command in every pane
# Usage: hsl <pane_count> <command>
hsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: hsl <pane_count> <command>"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="$PWD"
  local -a columns panes

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # Tile into a grid: ceil(sqrt(count)) columns, rows spread across them
  local cols=1
  while (( cols * cols < count )); do ((cols++)); done

  # Even columns come from splitting the rightmost one off at 1/(n-k+1) each time,
  # which keeps the array in left-to-right order
  columns=("$HERDR_PANE_ID")
  local k
  for (( k = 1; k < cols; k++ )); do
    columns+=("$(_herdr_split "${columns[-1]}" right "$(_herdr_ratio 1 $((cols - k + 1)))" "$current_dir")")
  done

  # Split each column into its share of rows, again evenly and top-to-bottom.
  # Indices run 1..cols here because zsh arrays start at 1.
  local col index rows j last
  for (( index = 1; index <= cols; index++ )); do
    col="${columns[index]}"
    rows=$(( count / cols ))
    (( index <= count % cols )) && (( rows++ ))
    panes+=("$col")
    last="$col"
    for (( j = 1; j < rows; j++ )); do
      last=$(_herdr_split "$last" down "$(_herdr_ratio 1 $((rows - j + 1)))" "$current_dir")
      panes+=("$last")
    done
  done

  local pane
  for pane in "${panes[@]}"; do
    herdr pane run "$pane" "$cmd" >/dev/null
  done
}
