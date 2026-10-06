#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/link-skills.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OWN_URL="git@github.com:sogamoso/skills.git"
# Not SKILLS_DIR — that name is read by the skills repo's own install.sh as the
# symlink *target*, and would send skills into this checkout instead of ~/.claude/skills.
OWN_DIR="${SKILLS_REPO_DIR:-$HOME/Code/sogamoso/skills}"

SENDAS_URL="git@github.com:sendasorg/skills.git"
SENDAS_DIR="${SENDAS_SKILLS_REPO_DIR:-$HOME/Code/sendasorg/skills}"

# Both personal repos are public, but cloned over SSH because they get pushed to.
# That makes a locked 1Password agent a failure mode even though nothing here is
# private: BatchMode turns it into a fast failure instead of a bootstrap-blocking
# prompt, and accept-new does the same for the host key on a machine with no
# known_hosts yet.
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

log_heading "Installing agent skills..."

# Prefer the plugin route when the source supports it on both agents; fall back
# to linking otherwise. The packaging decides the mechanism, so a source that
# ships a Codex plugin later switches over on the next run without an edit here.
add_source() {
  local repo_dir=$1 link_dir=$2 label=$3 url=${4:-}
  install_skill_plugin "$repo_dir" "$label" "$url" && return 0
  link_skills "$link_dir" "$label"
}

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
  [[ $url == git@* ]] && log_item "Unlock 1Password and enable its SSH agent, then rerun bootstrap"
  return 1
}

add_source "$REPO_DIR" "$REPO_DIR/skills" "dotfiles"

if sync_checkout "$OWN_URL" "$OWN_DIR" "sogamoso/skills"; then
  add_source "$OWN_DIR" "$OWN_DIR" "sogamoso/skills" "$OWN_URL"
fi

# Cloned because these are repos you work in; the plugins themselves come from
# the URL, so the skills still land on a machine where the clone was skipped.
if sync_checkout "$SENDAS_URL" "$SENDAS_DIR" "sendasorg/skills"; then
  add_source "$SENDAS_DIR" "$SENDAS_DIR" "sendasorg/skills" "$SENDAS_URL"
fi

# mattpocock used to be linked from this checkout before it moved to a Claude
# plugin; listing it here clears those links on machines that still have them.
prune_skill_links "$REPO_DIR/skills" "$OWN_DIR" "$SENDAS_DIR" "$HOME/Code/vendor/mattpocock-skills"

log_success "Agent skills installed"
