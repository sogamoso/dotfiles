#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Third-party plugins for Codex — the counterpart of claude-code.sh. sogamoso is
# installed by skills.sh, since it's the one plugin this repo owns.

if ! command -v codex &>/dev/null; then
  log_warn "Codex not installed, skipping plugin setup"
  exit 0
fi

log_heading "Adding Codex marketplaces..."

marketplaces=(
  "https://github.com/anthropics/claude-plugins-official.git"
  "https://github.com/obra/superpowers-marketplace.git"
  "https://github.com/SawyerHood/dev-browser.git"
  "https://github.com/jarrodwatts/claude-hud.git"
)

for marketplace in "${marketplaces[@]}"; do
  if codex plugin marketplace add "$marketplace" >/dev/null 2>&1; then
    log_item "$marketplace"
  else
    log_warn "Failed to add $marketplace"
  fi
done

log_heading "Installing Codex plugins..."

plugins=(
  "frontend-design@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "hookify@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "plugin-dev@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "code-review@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "ruby-lsp@claude-plugins-official"
  "dev-browser@dev-browser-marketplace"
  "superpowers@superpowers-marketplace"
  "episodic-memory@superpowers-marketplace"
  "claude-hud@claude-hud"
)

for plugin in "${plugins[@]}"; do
  if codex plugin add "$plugin" >/dev/null 2>&1; then
    log_item "$plugin"
  else
    log_warn "Failed to install $plugin"
  fi
done

log_success "Codex plugins installed"
