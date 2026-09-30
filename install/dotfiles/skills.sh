#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/link-skills.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PRIVATE_URL="git@github.com:sogamoso/skills.git"
# Not SKILLS_DIR — that name is read by the skills repo's own install.sh as the
# symlink *target*, and would send skills into this checkout instead of ~/.claude/skills.
PRIVATE_DIR="${SKILLS_REPO_DIR:-$HOME/Code/sogamoso/skills}"

# The private repo needs the 1Password SSH agent unlocked. BatchMode turns a
# locked agent into a fast failure instead of a bootstrap-blocking prompt;
# accept-new does the same for the host key on a machine with no known_hosts yet.
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

log_heading "Installing agent skills..."

# Keep a checkout current, or report why it isn't usable. Never fatal: skills
# are additive, and a locked keychain shouldn't cost the rest of bootstrap.
sync_checkout() {
  local url=$1 dir=$2 label=$3
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" pull --quiet --ff-only 2>/dev/null ||
      log_warn "$label: couldn't update $dir, using the existing checkout"
    return 0
  fi
  mkdir -p "$(dirname "$dir")"
  if git clone --quiet "$url" "$dir" 2>/dev/null; then
    log_item "$label: cloned into $dir"
    return 0
  fi
  log_warn "$label: couldn't clone $url, skipping"
  return 1
}

link_skills "$REPO_DIR/skills" "dotfiles"

if sync_checkout "$PRIVATE_URL" "$PRIVATE_DIR" "sogamoso/skills"; then
  link_skills "$PRIVATE_DIR" "sogamoso/skills"
else
  log_item "Sign in to 1Password and enable the SSH agent, then rerun bootstrap"
fi

log_success "Agent skills installed"
