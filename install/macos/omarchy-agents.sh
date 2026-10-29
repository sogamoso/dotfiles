#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_DIR/install/lib/omarchy-agents.sh"

# Checks out the pinned Omarchy commit the agents widget runs its usage
# collectors from. Sparse and blobless, so only the collectors' directories
# are materialized; rerunning moves an existing checkout to the pin, and
# `dotfiles reload` does.

log_heading "Installing Omarchy's agent usage collectors..."

if [[ ! -d $OMARCHY_AGENTS_DIR/.git ]]; then
  git clone --quiet --filter=blob:none --no-checkout https://github.com/basecamp/omarchy.git "$OMARCHY_AGENTS_DIR"
  git -C "$OMARCHY_AGENTS_DIR" sparse-checkout set "${OMARCHY_AGENTS_PATHS[@]}"
fi

# A fresh clone's HEAD can already be the pin with nothing checked out yet
if [[ "$(git -C "$OMARCHY_AGENTS_DIR" rev-parse HEAD 2>/dev/null)" == "$OMARCHY_AGENTS_COMMIT" &&
      -f $OMARCHY_AGENTS_DIR/shell/plugins/agents/collectors.py ]]; then
  log_item "Omarchy at ${OMARCHY_AGENTS_COMMIT:0:7} (up to date)"
else
  git -C "$OMARCHY_AGENTS_DIR" fetch --quiet origin "$OMARCHY_AGENTS_COMMIT"
  git -C "$OMARCHY_AGENTS_DIR" checkout --quiet --detach "$OMARCHY_AGENTS_COMMIT"
  log_item "Omarchy at ${OMARCHY_AGENTS_COMMIT:0:7}"
fi

if "$OMARCHY_AGENTS_PYTHON" -c 'import tomllib' 2>/dev/null; then
  log_success "Collectors ready"
else
  log_warn "$OMARCHY_AGENTS_PYTHON is missing or older than 3.11; the agents widget will show only Cursor and Gemini CLI"
fi
