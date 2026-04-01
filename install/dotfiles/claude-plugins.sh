#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if ! command -v claude &>/dev/null; then
  log_warn "Claude Code not installed, skipping plugin setup"
  exit 0
fi

log_heading "Adding Claude Code marketplaces..."

marketplaces=(
  "obra/superpowers-marketplace"
  "SawyerHood/dev-browser"
  "jarrodwatts/claude-hud"
)

for marketplace in "${marketplaces[@]}"; do
  if claude plugin marketplace add "$marketplace" 2>/dev/null; then
    log_item "$marketplace"
  else
    log_warn "Failed to add $marketplace"
  fi
done

log_heading "Installing Claude Code plugins..."

plugins=(
  "frontend-design@claude-plugins-official"
  "ralph-loop@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "hookify@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "plugin-dev@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "stagehand@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "ruby-lsp@claude-plugins-official"
  "dev-browser@dev-browser-marketplace"
  "superpowers@superpowers-marketplace"
  "episodic-memory@superpowers-marketplace"
  "claude-hud@claude-hud"
)

for plugin in "${plugins[@]}"; do
  if claude plugin install "$plugin" --scope user 2>/dev/null; then
    log_item "$plugin"
  else
    log_warn "Failed to install $plugin"
  fi
done

log_success "Claude Code plugins installed"
