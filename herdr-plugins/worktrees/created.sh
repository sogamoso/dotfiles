#!/usr/bin/env bash
set -euo pipefail

# The worktree.created hook. Trusts the new checkout's mise config, as hrw does,
# so a checkout made from the sidebar gets it too. Then follows the repo's
# paseo.json: worktree.setup runs in a tab of its own, which closes when setup
# succeeds and stays open on the error when it fails, and every entry in
# worktree.terminals gets a tab running its command. Agents don't wait for
# setup: hrw starts its agent alongside it.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

worktree=$(jq -r '.data.worktree.path' <<<"$HERDR_PLUGIN_EVENT_JSON")
workspace=$(jq -r '.data.workspace.workspace_id' <<<"$HERDR_PLUGIN_EVENT_JSON")

untrusted_checkout "$worktree" && exit 0

if command -v mise >/dev/null; then
  mise trust --quiet "$worktree" >/dev/null 2>&1 || true
fi

config="$worktree/paseo.json"
[[ -f $config ]] || exit 0

# A tab in the new workspace, left unfocused, running a command in its shell
# Usage: open_tab <label> [<command>]
open_tab() {
  local pane
  pane=$("$herdr" tab create --workspace "$workspace" --cwd "$worktree" --label "$1" --no-focus |
    jq -r '.result.root_pane.pane_id')
  [[ -n ${2:-} ]] && "$herdr" pane run "$pane" "$2" >/dev/null
  return 0
}

if jq -e '.worktree.setup // empty' "$config" >/dev/null; then
  open_tab setup "$(printf 'bash %q setup %q && exit' "$HERDR_PLUGIN_ROOT/paseo.sh" "$worktree")"
fi

jq -c '.worktree.terminals[]?' "$config" | while IFS= read -r terminal; do
  open_tab "$(jq -r '.name // "terminal"' <<<"$terminal")" "$(jq -r '.command // empty' <<<"$terminal")"
done
