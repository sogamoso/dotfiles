#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# ui.sh serves its skills over MCP rather than shipping files, so the stowed
# SKILL.md stubs are inert until this server is registered. The token is
# per-account, so it lives in 1Password rather than in this repo.
# By ID, not title: the vault also holds a Ui.sh login and software license,
# and op refuses to guess between them — or between signed-in accounts.
OP_ITEM="${UIDOTSH_OP_ITEM:-op://Private/3yq2epbxfzghrmhkml4dgo5jn4/credential}"
OP_ACCOUNT="${UIDOTSH_OP_ACCOUNT:-my.1password.com}"
MCP_URL="https://ui.sh/mcp?agent=claude"

log_heading "Registering the ui.sh MCP server..."

if claude mcp get uidotsh &>/dev/null; then
  log_success "uidotsh already registered"
  exit 0
fi

token="${UIDOTSH_TOKEN:-}"
if [[ -z $token ]] && command -v op &>/dev/null; then
  token="$(op read --account "$OP_ACCOUNT" "$OP_ITEM" 2>/dev/null || true)"
fi

if [[ -z $token ]]; then
  log_warn "No ui.sh token found, skipping"
  log_item "Unlock 1Password and check $OP_ITEM in $OP_ACCOUNT, or set UIDOTSH_TOKEN, then rerun bootstrap"
  exit 0
fi

claude mcp add --scope user --transport http uidotsh "$MCP_URL" \
  --header "Authorization: Bearer $token"

log_success "ui.sh MCP server registered"
