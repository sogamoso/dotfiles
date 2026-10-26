#!/usr/bin/env bash
set -euo pipefail

# Opens a tab in the workspace for every worktree.terminals entry in the repo's
# paseo.json, running its command, as Paseo does. created.sh runs it straight
# away, or from the setup tab once setup has succeeded.
# Usage: terminals.sh <workspace> <worktree>

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

workspace="$1"
worktree="$2"
config=$(paseo_config "$worktree") || exit 0

[[ -f $config ]] || exit 0
untrusted_checkout "$worktree" && exit 0

jq -c '.worktree.terminals[]?' "$config" | while IFS= read -r terminal; do
  open_tab "$workspace" "$worktree" "$(jq -r '.name // "terminal"' <<<"$terminal")" "$(jq -r '.command // empty' <<<"$terminal")"
done
