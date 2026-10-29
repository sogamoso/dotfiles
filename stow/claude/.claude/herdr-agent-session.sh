#!/usr/bin/env bash
# Claude Code's SessionStart hook. Hands the session to herdr's own hook, which
# is what lets a herdr restart resume the conversation in this pane, except in
# a repo's own checkout. Agents belong in worktrees; a conversation started in
# the checkout itself is a one-off, and it should end with the pane rather than
# come back after every reboot. Workspaces outside a repo resume as before.
set -euo pipefail

hook="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/herdr-agent-state.sh"
input=$(cat)

[[ ${HERDR_ENV:-} == "1" && -n ${HERDR_WORKSPACE_ID:-} && -f $hook ]] || exit 0

# herdr reports worktree provenance for any workspace in a repo; is_linked_worktree
# false is the repo's own checkout, the parent of its worktrees.
if "${HERDR_BIN_PATH:-herdr}" workspace get "$HERDR_WORKSPACE_ID" 2>/dev/null | python3 -I -c '
import json, sys
worktree = json.load(sys.stdin)["result"]["workspace"].get("worktree")
sys.exit(0 if worktree and not worktree["is_linked_worktree"] else 1)
' 2>/dev/null; then
  exit 0
fi

printf '%s' "$input" | bash "$hook" session
