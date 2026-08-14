#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_URL="git@github.com:sogamoso/skills.git"
# Not SKILLS_DIR — that name is read by the skills repo's own install.sh as the
# symlink *target*, and would send skills into this checkout instead of ~/.claude/skills.
CHECKOUT="${SKILLS_REPO_DIR:-$HOME/Code/personal/skills}"

# The repo is private, so this needs the 1Password SSH agent unlocked. BatchMode
# turns a locked agent into a fast failure instead of a bootstrap-blocking prompt;
# accept-new does the same for the host key on a machine with no known_hosts yet.
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

log_heading "Installing Claude skills..."

if [[ -d "$CHECKOUT/.git" ]]; then
  if git -C "$CHECKOUT" pull --quiet --ff-only 2>/dev/null; then
    log_item "Updated $CHECKOUT"
  else
    log_warn "Couldn't update $CHECKOUT, using the existing checkout"
  fi
else
  mkdir -p "$(dirname "$CHECKOUT")"
  if ! git clone --quiet "$REPO_URL" "$CHECKOUT" 2>/dev/null; then
    log_warn "Couldn't clone $REPO_URL, skipping skills"
    log_item "Sign in to 1Password and enable the SSH agent, then rerun bootstrap"
    exit 0
  fi
  log_item "Cloned into $CHECKOUT"
fi

if [[ ! -f "$CHECKOUT/scripts/install.sh" ]]; then
  log_warn "No scripts/install.sh in $CHECKOUT, skipping skills"
  exit 0
fi

bash "$CHECKOUT/scripts/install.sh"

log_success "Claude skills installed"
