#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/link-skills.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OWN_URL="git@github.com:sogamoso/skills.git"
# Not SKILLS_DIR — that name is read by the skills repo's own install.sh as the
# symlink *target*, and would send skills into this checkout instead of ~/.claude/skills.
OWN_DIR="${SKILLS_REPO_DIR:-$HOME/Code/sogamoso/skills}"

# The ui.sh stubs live in a private repo: the ui.sh license forbids
# redistributing what it scaffolds, and this one is public.
UIDOTSH_URL="git@github.com:sogamoso/uidotsh-archive.git"
UIDOTSH_DIR="${UIDOTSH_ARCHIVE_DIR:-$HOME/Code/sogamoso/uidotsh-archive}"

# Both repos are private and cloned over SSH because they get pushed to, so a
# locked 1Password agent is a failure mode: BatchMode turns it into a fast
# failure instead of a bootstrap-blocking prompt, and accept-new does the same
# for the host key on a machine with no known_hosts yet.
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

# local/ only exists after the archive's restore.py has built offline copies
# from a snapshot, which is how the skills keep working without a subscription.
if sync_checkout "$UIDOTSH_URL" "$UIDOTSH_DIR" "uidotsh-archive"; then
  if [[ -d $UIDOTSH_DIR/local ]]; then
    link_skills "$UIDOTSH_DIR/local" "ui.sh (archived)"
  else
    link_skills "$UIDOTSH_DIR/stubs" "ui.sh stubs"
  fi
fi

# Cloned because it's a repo you work in; the plugin itself comes from the URL,
# so the skills still land on a machine where the clone was skipped.
if sync_checkout "$OWN_URL" "$OWN_DIR" "sogamoso/skills"; then
  add_source "$OWN_DIR" "$OWN_DIR" "sogamoso/skills" "$OWN_URL"
fi

# The plugin was renamed from sogamoso to sogamoso-skills; drop the old install
# so Codex doesn't load every skill twice and Claude doesn't keep a dead entry.
if command -v claude &>/dev/null; then
  claude plugin uninstall sogamoso@sogamoso >/dev/null 2>&1 || true
fi
if command -v codex &>/dev/null; then
  codex plugin remove sogamoso@sogamoso >/dev/null 2>&1 || true
fi

# The ui.sh stubs used to be linked from this repo's skills/, and mattpocock
# from a vendor checkout; listing both clears those links on machines that
# still have them.
prune_skill_links "$UIDOTSH_DIR/stubs" "$UIDOTSH_DIR/local" "$OWN_DIR" "$REPO_DIR/skills" "$HOME/Code/vendor/mattpocock-skills"

log_success "Agent skills installed"
