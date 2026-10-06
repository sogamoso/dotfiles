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
)

for marketplace in "${marketplaces[@]}"; do
  if codex plugin marketplace add "$marketplace" >/dev/null 2>&1; then
    log_item "$marketplace"
  else
    log_warn "Failed to add $marketplace"
  fi
done

log_heading "Installing Codex plugins..."

# Only plugins Codex can actually use. Ones that are only slash commands,
# subagents or Claude hooks (code-review, feature-dev, pr-review-toolkit,
# code-simplifier, security-guidance, hookify, plugin-dev) stay in claude-code.sh.
plugins=(
  "frontend-design@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "ruby-lsp@claude-plugins-official"
  "dev-browser@dev-browser-marketplace"
  "superpowers@superpowers-marketplace"
  "episodic-memory@superpowers-marketplace"
)

for plugin in "${plugins[@]}"; do
  if codex plugin add "$plugin" >/dev/null 2>&1; then
    log_item "$plugin"
  else
    log_warn "Failed to install $plugin"
  fi
done

log_success "Codex plugins installed"
