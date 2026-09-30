#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/link-skills.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PRIVATE_URL="git@github.com:sogamoso/skills.git"
# Not SKILLS_DIR — that name is read by the skills repo's own install.sh as the
# symlink *target*, and would send skills into this checkout instead of ~/.claude/skills.
PRIVATE_DIR="${SKILLS_REPO_DIR:-$HOME/Code/sogamoso/skills}"

MATT_URL="https://github.com/mattpocock/skills.git"
MATT_DIR="${MATT_SKILLS_REPO_DIR:-$HOME/Code/vendor/mattpocock-skills}"

# Names we refuse to let a source shadow. Explicit, not discovered: which
# plugins are installed varies per machine, and link names must not. A source
# wanting one of these gets its skill linked under the source's prefix instead.
# code-review: Claude Code ships an unqualified built-in by that name, and
# mattpocock's is model-invocable, so it would compete for automatic selection
# too — not just for the slash command.
SKILLS_RESERVED="code-review"

# The private repo needs the 1Password SSH agent unlocked. BatchMode turns a
# locked agent into a fast failure instead of a bootstrap-blocking prompt;
# accept-new does the same for the host key on a machine with no known_hosts yet.
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

log_heading "Installing agent skills..."

# Prefer the plugin route when the source supports it on both agents; fall back
# to linking otherwise. The packaging decides the mechanism, so a source that
# ships a Codex plugin later switches over on the next run without an edit here.
add_source() {
  local repo_dir=$1 link_dir=$2 label=$3
  install_skill_plugin "$repo_dir" "$label" && return 0
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
  return 1
}

LINK_SKILLS_PREFIX=dotfiles add_source "$REPO_DIR" "$REPO_DIR/skills" "dotfiles"

if sync_checkout "$PRIVATE_URL" "$PRIVATE_DIR" "sogamoso/skills"; then
  LINK_SKILLS_PREFIX=sogamoso add_source "$PRIVATE_DIR" "$PRIVATE_DIR" "sogamoso/skills"
else
  log_item "Sign in to 1Password and enable the SSH agent, then rerun bootstrap"
fi

# in-progress/ is upstream's own staging area — the skills there get reshaped
# without notice, so take only the sets Matt considers shipped.
if sync_checkout "$MATT_URL" "$MATT_DIR" "mattpocock/skills"; then
  LINK_SKILLS_EXCLUDE=in-progress LINK_SKILLS_PREFIX=mattpocock \
    add_source "$MATT_DIR" "$MATT_DIR/skills" "mattpocock/skills"
fi

prune_skill_links "$REPO_DIR/skills" "$PRIVATE_DIR" "$MATT_DIR"

log_success "Agent skills installed"
