#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if ! command -v claude &>/dev/null; then
  log_warn "Claude Code not installed, skipping plugin setup"
  exit 0
fi

log_heading "Adding Claude Code marketplaces..."

marketplaces=(
  "jarrodwatts/claude-hud"
  "cursor/plugins"
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
  "feature-dev@claude-plugins-official"
  "hookify@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "plugin-dev@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "code-review@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "ruby-lsp@claude-plugins-official"
  "pstack@cursor-plugins"
  "claude-hud@claude-hud"
)

for plugin in "${plugins[@]}"; do
  if claude plugin install "$plugin" --scope user 2>/dev/null; then
    log_item "$plugin"
  else
    log_warn "Failed to install $plugin"
  fi
done

# Retired 2026-11-16 after a usage review: dev-browser never ran (the
# built-in browser covers it), episodic-memory was searched in 4 of 299
# sessions and kept a 535 MB copy of every transcript (pstack's recall reads
# them directly), and mattpocock-skills loaded 27 skills to use 2, which now
# ship in sogamoso-skills as pr and writing-for-agents. Remove them where an
# earlier run installed them, so every machine converges.
for plugin in dev-browser@dev-browser-marketplace episodic-memory@superpowers-marketplace \
  mattpocock-skills@mattpocock superpowers@superpowers-marketplace; do
  claude plugin uninstall "$plugin" --scope user >/dev/null 2>&1 || true
done
for marketplace in dev-browser-marketplace mattpocock superpowers-marketplace; do
  claude plugin marketplace remove "$marketplace" >/dev/null 2>&1 || true
done

log_heading "Configuring claude-hud..."

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HUD_CONFIG_DIR="$CLAUDE_DIR/plugins/claude-hud"
mkdir -p "$HUD_CONFIG_DIR"
cat > "$HUD_CONFIG_DIR/config.json" << 'JSON'
{
  "gitStatus": {
    "showAheadBehind": true
  },
  "display": {
    "showTodos": true,
    "showModel": false
  }
}
JSON
log_success "claude-hud configured"

log_success "Claude Code plugins installed"
