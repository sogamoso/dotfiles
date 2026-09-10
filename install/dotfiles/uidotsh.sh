#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# ui.sh serves its skills over MCP rather than shipping files, so the stowed
# SKILL.md stubs are inert until this server is registered. The token is
# per-account, so it lives in 1Password rather than in this repo.
OP_ITEM="${UIDOTSH_OP_ITEM:-op://Private/ui.sh/credential}"
MCP_URL="https://ui.sh/mcp?agent=claude"

log_heading "Registering the ui.sh MCP server..."

if claude mcp get uidotsh &>/dev/null; then
  log_success "uidotsh already registered"
  exit 0
fi

token="${UIDOTSH_TOKEN:-}"
if [[ -z $token ]] && command -v op &>/dev/null; then
  token="$(op read "$OP_ITEM" 2>/dev/null || true)"
fi

if [[ -z $token ]]; then
  log_warn "No ui.sh token found, skipping"
  log_item "Store it at $OP_ITEM or set UIDOTSH_TOKEN, then rerun bootstrap"
  exit 0
fi

claude mcp add --scope user --transport http uidotsh "$MCP_URL" \
  --header "Authorization: Bearer $token"

log_success "ui.sh MCP server registered"
