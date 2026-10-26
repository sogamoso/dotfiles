# Review layouts: agent left, hunk diff watch top right, terminal bottom right.
#
# Not an Omarchy port, so unlike herdr.zsh this pair carries a bash copy. The
# bodies stay byte-identical, which keeps them to syntax both shells share:
# no arrays, and subdirectories come from find rather than a glob.

# Subdirectories of the current directory, hidden ones skipped, one per line
_layout_subdirs() {
  find "$PWD" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort
}

# The default agent's name: Omarchy's on Omarchy, the one `dotfiles agent` sets
# on macOS, or nothing when neither is chosen
# Usage: _layout_default_agent_name
_layout_default_agent_name() {
  if command -v omarchy-default-agent >/dev/null; then
    omarchy-default-agent
  elif command -v dotfiles >/dev/null; then
    dotfiles agent 2>/dev/null
  fi
}

# The agent to run when none is given: the default agent through its `a` alias
# when one is chosen, Claude Code through `cx` otherwise
# Usage: _layout_default_agent
_layout_default_agent() {
  if [[ -n $(_layout_default_agent_name) ]]; then
    echo a
  else
    echo cx
  fi
}

# The harness an agent command runs, for naming its worktree branch. Covers
# Omarchy's agent aliases and the agents `omarchy default agent` offers.
# Usage: _layout_harness <agent>
_layout_harness() {
  local cmd="${1%% *}"
  [[ $cmd == "a" ]] && cmd=$(_layout_default_agent_name)

  case "$cmd" in
    cx|claude) echo claude ;;
    cy|codex) echo codex ;;
    c|opencode) echo opencode ;;
    cursor-agent) echo cursor ;;
    kiro-cli) echo kiro ;;
    agy|amp|commandcode|copilot|crush|devin|dsh|freebuff|gemini|grok|hermes|kilo|kimi|mcode|muse|omp|openclaw|ori|pi|qwen) echo "$cmd" ;;
    *) echo agent ;;
  esac
}

# The first <prefix>-<n> that isn't a local branch yet
# Usage: _layout_free_branch <prefix>
_layout_free_branch() {
  local n=1
  while git show-ref --verify --quiet "refs/heads/$1-$n"; do (( n++ )); done
  echo "$1-$n"
}

# An agent command that starts on a task, using each harness's own spelling
# for an initial prompt, as omarchy-agent does. Fails for a harness without one.
# Usage: _layout_with_prompt <agent> <prompt>
_layout_with_prompt() {
  local quoted
  printf -v quoted '%q' "$2"

  if [[ ${1%% *} == "a" ]]; then
    if command -v omarchy-agent >/dev/null; then
      printf '%s\n' "omarchy-agent --inline --prompt $quoted"
    else
      printf '%s\n' "dotfiles agent run --prompt $quoted"
    fi
    return
  fi

  case "$(_layout_harness "$1")" in
    claude|codex|commandcode|grok|mcode|muse|omp) printf '%s\n' "$1 -- $quoted" ;;
    opencode) printf '%s\n' "$1 --prompt $quoted" ;;
    cursor) printf '%s\n' "$1 agent -- $quoted" ;;
    agy|gemini) printf '%s\n' "$1 --prompt-interactive $quoted" ;;
    copilot) printf '%s\n' "$1 --interactive $quoted" ;;
    crush) printf '%s\n' "$1 run $quoted" ;;
    kilo) printf '%s\n' "$1 --prompt=$quoted" ;;
    kimi) printf '%s\n' "$1 --prompt $quoted" ;;
    ori) printf '%s\n' "$1 --interactive --prompt $quoted" ;;
    pi) printf '%s\n' "$1 $quoted" ;;
    qwen) printf '%s\n' "$1 --prompt-interactive=$quoted" ;;
    amp) printf '%s\n' "$1 <<< $quoted" ;;
    *) echo "No known way to give $1 a task." >&2; return 1 ;;
  esac
}

# Trust a new checkout's mise config, as Omarchy's ga does, so the agent and
# terminal don't stop to ask
# Usage: _layout_mise_trust <dir>
_layout_mise_trust() {
  command -v mise >/dev/null && mise trust --quiet "$1" >/dev/null 2>&1
  return 0
}

# Review layout in the current herdr tab
# Usage: hrl [<agent>]
hrl() {
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hrl."; return 1; }

  local current_dir="$PWD"
  local agent="${1:-$(_layout_default_agent)}"
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

  local agent="${1:-$(_layout_default_agent)}"
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

# Review layout on a fresh worktree off origin/main, in a workspace of its own
# that herdr groups under the repo's. Without a name the branch is named after
# the agent's harness, as in claude-1 or codex-2. A task, when given, is the
# agent's first prompt. A herdr key binding runs it too, where only
# HERDR_ACTIVE_PANE_ID is set.
# Usage: hrw [<name>] [<agent>] [<task>]
hrw() {
  [[ -z ${HERDR_PANE_ID:-$HERDR_ACTIVE_PANE_ID} ]] && { echo "You must start herdr to use hrw."; return 1; }
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "hrw must run inside a git repository."; return 1; }

  local name="${1:-}"
  local agent="${2:-$(_layout_default_agent)}"
  local task="${3:-}"
  local agent_command="$agent"
  local response pane_id

  if [[ -n $task ]]; then
    agent_command=$(_layout_with_prompt "$agent" "$task") || return 1
  fi

  git fetch --quiet origin main || return 1

  [[ -z $name ]] && name=$(_layout_free_branch "$(_layout_harness "$agent")")

  response=$(herdr worktree create --cwd "$PWD" --branch "$name" --base origin/main --label "$name" --focus 2>&1)
  pane_id=$(jq -r '.result.root_pane.pane_id // empty' <<<"$response")
  [[ -z $pane_id ]] && { jq -r '.error.message' <<<"$response"; return 1; }

  _layout_mise_trust "$(jq -r '.result.root_pane.cwd' <<<"$response")"
  herdr pane run "$pane_id" "$(printf 'hrl %q' "$agent_command")" >/dev/null
}

# Ask for an agent, a task and an optional branch name, then run hrw with them.
# What prefix+shift+a opens in a herdr popup. Escape at any prompt cancels.
# Usage: hra
hra() {
  local agent task name candidate
  local agents=""

  for candidate in $(_layout_default_agent) cx cy c cursor-agent gemini agy amp copilot crush grok kilo kimi mcode muse omp ori pi qwen commandcode; do
    [[ $candidate == "a" ]] && { agents+="a"$'\n'; continue; }
    [[ $agents == *"$candidate"$'\n'* ]] && continue
    command -v "$candidate" >/dev/null 2>&1 && agents+="$candidate"$'\n'
  done

  agent=$(printf '%s' "$agents" | gum choose --header "Agent") || return 0
  task=$(gum input --placeholder "Task for $agent (blank to start without one)") || return 0
  name=$(gum input --placeholder "Branch (blank for $(_layout_harness "$agent")-<n>)") || return 0

  hrw "$name" "$agent" "$task"
}

# Finish an agent: delete its branch and remove its worktree, which closes its
# workspace, after a confirmation, as Omarchy's gd does. Runs from any pane in
# the agent's workspace, or from a herdr key binding.
# Usage: hrd
hrd() {
  local workspace="${HERDR_WORKSPACE_ID:-$HERDR_ACTIVE_WORKSPACE_ID}"
  [[ -z $workspace ]] && { echo "You must start herdr to use hrd."; return 1; }

  local worktree branch worktree_dir response

  worktree=$(herdr worktree list --workspace "$workspace" 2>/dev/null |
    jq -c --arg ws "$workspace" '.result.worktrees[]? | select(.open_workspace_id == $ws and .is_linked_worktree)')
  [[ -z $worktree ]] && { echo "hrd must run in an agent's worktree workspace."; return 1; }

  branch=$(jq -r '.branch // empty' <<<"$worktree")
  worktree_dir=$(jq -r '.path' <<<"$worktree")

  gum confirm "Remove the ${branch:-detached} worktree and delete its branch?" || return 0

  # Off the branch first so it can go now: removing the worktree closes this
  # workspace, and this shell with it when hrd runs from one of its panes
  if [[ -n $branch ]]; then
    git -C "$worktree_dir" checkout --quiet --detach || return 1
    git -C "$worktree_dir" branch --quiet -D "$branch" || return 1
  fi

  response=$(herdr worktree remove --workspace "$workspace" --force 2>&1) ||
    { jq -r '.error.message // empty' <<<"$response"; return 1; }
}

# Review layout in the current tmux window
# Usage: trl [<agent>]
trl() {
  [[ -z $TMUX ]] && { echo "You must start tmux to use trl."; return 1; }

  local current_dir="$PWD"
  local agent="${1:-$(_layout_default_agent)}"
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

  local agent="${1:-$(_layout_default_agent)}"
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

# Review layout on a fresh worktree off origin/main, in a window of its own.
# The checkout goes where herdr would put it, so herdr can open it too.
# Without a name the branch is named after the agent's harness, as in hrw, and
# a task, when given, is the agent's first prompt.
# Usage: trw [<name>] [<agent>] [<task>]
trw() {
  [[ -z $TMUX ]] && { echo "You must start tmux to use trw."; return 1; }
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "trw must run inside a git repository."; return 1; }

  local name="${1:-}"
  local agent="${2:-$(_layout_default_agent)}"
  local task="${3:-}"
  local agent_command="$agent"
  local repo_root worktree_dir pane_id

  if [[ -n $task ]]; then
    agent_command=$(_layout_with_prompt "$agent" "$task") || return 1
  fi

  git fetch --quiet origin main || return 1

  [[ -z $name ]] && name=$(_layout_free_branch "$(_layout_harness "$agent")")

  # The main checkout, even when run from inside another worktree
  repo_root=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
  worktree_dir="$HOME/.herdr/worktrees/$(basename "$repo_root")/${name//\//-}"

  if git show-ref --verify --quiet "refs/heads/$name"; then
    git worktree add --quiet "$worktree_dir" "$name" || return 1
  else
    git worktree add --quiet -b "$name" "$worktree_dir" origin/main || return 1
  fi

  _layout_mise_trust "$worktree_dir"
  pane_id=$(tmux new-window -c "$worktree_dir" -n "$name" -P -F '#{pane_id}')
  tmux send-keys -t "$pane_id" "$(printf 'trl %q' "$agent_command")" C-m
}

# Finish the agent in this window: delete its branch, remove its worktree and
# close the window, after a confirmation, as Omarchy's gd does
# Usage: trd
trd() {
  [[ -z $TMUX ]] && { echo "You must start tmux to use trd."; return 1; }

  local git_dir common_dir branch worktree_dir

  git_dir=$(git rev-parse --path-format=absolute --git-dir 2>/dev/null)
  common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  [[ -z $git_dir || $git_dir == "$common_dir" ]] && { echo "trd must run inside an agent's worktree."; return 1; }

  branch=$(git branch --show-current)
  worktree_dir=$(git rev-parse --show-toplevel)

  gum confirm "Remove the ${branch:-detached} worktree and delete its branch?" || return 0

  if [[ -n $branch ]]; then
    git checkout --quiet --detach || return 1
    git branch --quiet -D "$branch" || return 1
  fi

  cd "$(dirname "$common_dir")" || return 1
  git worktree remove --force "$worktree_dir" || return 1
  tmux kill-window -t "$TMUX_PANE"
}
