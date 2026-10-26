#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Installs the third-party herdr plugins, then links every plugin under
# herdr-plugins/ from this checkout. Linked, not stowed: herdr records a plugin
# by the real path of its manifest, so a stow link would resolve back here
# anyway. Linking again only rewrites that record, so this is cheap to rerun,
# and `dotfiles reload` does.

command -v herdr >/dev/null || exit 0

# Third-party plugins run as this user, agents launched with their approvals
# off included, so each is pinned to a commit whose code was read first. Bump a
# pin only after reading what changed since. Shared with `dotfiles doctor`.
source "$REPO_DIR/install/lib/herdr-plugins.sh"

log_heading "Installing herdr plugins..."

failed=""
for entry in "${HERDR_THIRD_PARTY_PLUGINS[@]}"; do
  read -r id source commit <<<"$entry"
  installed=$(herdr plugin list --plugin "$id" --json 2>/dev/null |
    jq -r '.result.plugins[0].source.resolved_commit // empty' 2>/dev/null || true)
  if [[ $installed == "$commit" ]]; then
    log_item "$id (up to date)"
  elif herdr plugin install "$source" --ref "$commit" --yes >/dev/null; then
    log_item "$id"
  else
    failed+=" $id"
  fi
done

[[ -n $failed ]] && log_warn "Could not install:$failed"

log_heading "Linking herdr plugins..."

failed=""
for plugin in "$REPO_DIR"/herdr-plugins/*/; do
  plugin="${plugin%/}"
  if herdr plugin link "$plugin" >/dev/null; then
    log_item "$(basename "$plugin")"
  else
    failed+=" $(basename "$plugin")"
  fi
done

if [[ -n $failed ]]; then
  log_warn "Could not link:$failed"
else
  log_success "herdr plugins linked"
fi

# A running server keeps the keys it started with, so a key bound to a plugin
# action, newly stowed or pulled, waits for this. Nothing to do with none running.
herdr server reload-config >/dev/null 2>&1 || true
