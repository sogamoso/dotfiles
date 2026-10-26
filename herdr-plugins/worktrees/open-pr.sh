#!/usr/bin/env bash
set -euo pipefail

# The open-pr action, run by a Ctrl-click on a pull request link. The worktree
# plugin (mkdir700/herdr-plugin-worktree) already imports pull requests, but it
# only asks for one in its prompt, so this opens that prompt and answers it: the
# link, then the default agent. Its prompt is opened as an overlay rather than
# its usual popup, since only a pane has an id to type into, and from the repo's
# main workspace, since herdr creates worktrees only from there. Nothing is on
# screen before the prompt opens, so an earlier failure becomes a notification.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

url="${HERDR_PLUGIN_CLICKED_URL:-}"
[[ $url =~ ^https://github\.com/([^/]+/[^/]+)/pull/[0-9]+ ]] || exit 0
slug=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')

fail() {
  "$herdr" notification show "Can't open the pull request" --body "$1" >/dev/null
  exit 1
}

cwd=$(jq -r '.focused_pane_cwd // .workspace_cwd // empty' <<<"$HERDR_PLUGIN_CONTEXT_JSON")
[[ $(github_slug "${cwd:-/}") == "$slug" ]] ||
  fail "Ctrl-click it from a pane in a checkout of $slug."

main=$(main_checkout "$cwd")
workspace=$("$herdr" worktree list --cwd "$main" 2>/dev/null |
  jq -r '.result.worktrees[]? | select(.is_linked_worktree | not) | .open_workspace_id // empty' | head -n 1)
[[ -n $workspace ]] || fail "Open a workspace on $main first."

pane=$("$herdr" plugin pane open --plugin worktree --entrypoint prompt --placement overlay \
  --workspace "$workspace" --focus 2>/dev/null | jq -r '.result.plugin_pane.pane.pane_id // empty' || true)
[[ -n $pane ]] || fail "The worktree plugin isn't installed. Run dotfiles reload."

"$herdr" pane wait-output "$pane" --match "or branch name:" --timeout 15000 >/dev/null
"$herdr" pane run "$pane" "$url" >/dev/null
"$herdr" pane wait-output "$pane" --match "Agent [" --timeout 15000 >/dev/null
"$herdr" pane send-keys "$pane" Enter >/dev/null
