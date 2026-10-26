#!/usr/bin/env bash
set -euo pipefail

# The worktree.created hook. Trusts the new checkout's mise config, as hrw does,
# so a checkout made from the sidebar gets it too. Then follows the repo's
# paseo.json: worktree.setup runs in a tab of its own, which closes when setup
# succeeds and stays open on the error when it fails, and the worktree.terminals
# tabs open once setup has succeeded, since they may need what it installs.
# Agents don't wait for setup: hrw starts its agent alongside it.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

worktree=$(jq -r '.data.worktree.path' <<<"$HERDR_PLUGIN_EVENT_JSON")
workspace=$(jq -r '.data.workspace.workspace_id' <<<"$HERDR_PLUGIN_EVENT_JSON")

untrusted_checkout "$worktree" && exit 0

if command -v mise >/dev/null; then
  mise trust --quiet "$worktree" >/dev/null 2>&1 || true
fi

config="$worktree/paseo.json"
[[ -f $config ]] || exit 0

if jq -e '.worktree.setup // empty' "$config" >/dev/null; then
  open_tab "$workspace" "$worktree" setup "$(printf 'bash %q setup %q && bash %q %q %q && exit' \
    "$HERDR_PLUGIN_ROOT/paseo.sh" "$worktree" "$HERDR_PLUGIN_ROOT/terminals.sh" "$workspace" "$worktree")"
else
  bash "$HERDR_PLUGIN_ROOT/terminals.sh" "$workspace" "$worktree"
fi
