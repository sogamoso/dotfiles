#!/usr/bin/env bash
# Runs a prompt through the coding agent the Omarchy workflows use, unattended.
# The OMARCHY_AGENT repository variable picks it (claude or codex), and nothing
# here assumes one, so switching agents is a settings change. The job calling
# this holds a read-only token, so the agent can edit files and commit locally
# but not push; a separate job checks its work and publishes it.
#
# Usage: omarchy-agent.sh install
#        omarchy-agent.sh run <prompt>
set -euo pipefail

agent=${OMARCHY_AGENT:?Set the OMARCHY_AGENT repository variable to claude or codex}

# What Claude may run: reading Omarchy through gh, the review commands, the
# repo's checks, and local git. Nothing that pushes, and the token gh gets is
# read-only, so an API call can't change anything either.
claude_tools=(
  Read Edit Write Glob Grep
  "Bash(gh api:*)" "Bash(gh pr view:*)" "Bash(gh pr diff:*)"
  "Bash(dotfiles omarchy-downstream-candidates:*)"
  "Bash(python3 .github/check.py)" "Bash(bash -n:*)" "Bash(zsh -n:*)"
  "Bash(diff:*)" "Bash(cmp:*)"
  "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)"
  "Bash(git add:*)" "Bash(git rm:*)" "Bash(git mv:*)" "Bash(git commit:*)"
)

case "$agent:${1:-}" in
  claude:install)
    npm install -g @anthropic-ai/claude-code
    ;;
  codex:install)
    npm install -g @openai/codex
    printenv OPENAI_API_KEY | codex login --with-api-key
    ;;
  claude:run)
    claude -p "${2:?run needs a prompt}" --permission-mode acceptEdits \
      --allowedTools "$(IFS=,; echo "${claude_tools[*]}")"
    ;;
  codex:run)
    # The sandbox keeps writes inside the checkout; gh needs the network
    codex exec --full-auto -c sandbox_workspace_write.network_access=true \
      "${2:?run needs a prompt}"
    ;;
  *)
    echo "Usage: OMARCHY_AGENT=claude|codex $0 install | run <prompt>" >&2
    exit 64
    ;;
esac
