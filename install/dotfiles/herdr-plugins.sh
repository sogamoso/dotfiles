#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Links every plugin under herdr-plugins/ from this checkout. Linked, not
# stowed: herdr records a plugin by the real path of its manifest, so a stow
# link would resolve back here anyway. Linking again only rewrites that record,
# so this is cheap to rerun, and `dotfiles reload` does.

command -v herdr >/dev/null || exit 0

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
