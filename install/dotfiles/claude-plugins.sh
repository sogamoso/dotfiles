#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if ! command -v claude &>/dev/null; then
  log_warn "Claude Code not installed, skipping plugin setup"
  exit 0
fi

log_heading "Installing Claude Code plugins..."

plugins=(
  "frontend-design@claude-code-plugins"
  "ralph-wiggum@claude-code-plugins"
  "feature-dev@claude-code-plugins"
  "hookify@claude-code-plugins"
  "pr-review-toolkit@claude-code-plugins"
  "plugin-dev@claude-code-plugins"
  "security-guidance@claude-code-plugins"
  "code-simplifier@claude-code-plugins"
  "stagehand@claude-code-plugins"
  "typescript@claude-code-plugins"
  "ruby@claude-code-plugins"
  "dev-browser@dev-browser-marketplace"
  "superpowers@superpowers-marketplace"
  "episodic-memory@superpowers-marketplace"
)

for plugin in "${plugins[@]}"; do
  if claude plugin install "$plugin" --scope user 2>/dev/null; then
    log_item "$plugin"
  else
    log_warn "Failed to install $plugin"
  fi
done

log_success "Claude Code plugins installed"
