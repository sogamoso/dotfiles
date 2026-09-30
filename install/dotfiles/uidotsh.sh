#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# ui.sh serves its skills over MCP rather than shipping files, so the linked
# SKILL.md stubs are inert until this server is registered. The token is
# per-account, so it lives in 1Password rather than in this repo.
# By ID, not title: the vault also holds a Ui.sh login and software license,
# and op refuses to guess between them — or between signed-in accounts.
OP_ITEM="${UIDOTSH_OP_ITEM:-op://Private/3yq2epbxfzghrmhkml4dgo5jn4/credential}"
OP_ACCOUNT="${UIDOTSH_OP_ACCOUNT:-my.1password.com}"

# Claude Code stores the bearer token itself; Codex only takes the name of an
# environment variable and reads it at launch, so the token also has to sit
# somewhere the shells can export it from. Not in the repo, and not in TMPDIR —
# it has to survive a reboot.
TOKEN_ENV_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/uidotsh.env"

log_heading "Registering the ui.sh MCP server..."

LAUNCH_LABEL="com.sogamoso.uidotsh-token"

has() { command -v "$1" &>/dev/null; }
claude_done() { ! has claude || claude mcp get uidotsh &>/dev/null; }
codex_done() { ! has codex || codex mcp get uidotsh &>/dev/null; }
launchenv_done() {
  [[ "$(uname -s)" == "Darwin" ]] || return 0
  launchctl print "gui/$(id -u)/$LAUNCH_LABEL" &>/dev/null
}

if claude_done && codex_done && launchenv_done && [[ -r $TOKEN_ENV_FILE ]]; then
  log_success "uidotsh already registered"
  exit 0
fi

token="${UIDOTSH_TOKEN:-}"
if [[ -z $token ]] && has op; then
  token="$(op read --account "$OP_ACCOUNT" "$OP_ITEM" 2>/dev/null || true)"
fi

if [[ -z $token ]]; then
  log_warn "No ui.sh token found, skipping"
  log_item "Unlock 1Password and check $OP_ITEM in $OP_ACCOUNT, or set UIDOTSH_TOKEN, then rerun bootstrap"
  exit 0
fi

mkdir -p "$(dirname "$TOKEN_ENV_FILE")"
printf 'export UIDOTSH_TOKEN=%q\n' "$token" > "$TOKEN_ENV_FILE"
chmod 600 "$TOKEN_ENV_FILE"

# Codex started from ChatGPT.app gets the launchd session environment rather
# than a shell's, so the shell supplements never reach it. This agent republishes
# the token into that session at login. See the script for the exposure this buys.
plist="$HOME/Library/LaunchAgents/$LAUNCH_LABEL.plist"
if [[ "$(uname -s)" == "Darwin" && -f $plist ]]; then
  launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist"
  launchctl enable "gui/$(id -u)/$LAUNCH_LABEL"
  log_item "Published the token to the launchd session for GUI-launched Codex"
fi

if has claude && ! claude mcp get uidotsh &>/dev/null; then
  claude mcp add --scope user --transport http uidotsh "https://ui.sh/mcp?agent=claude" \
    --header "Authorization: Bearer $token"
  log_item "Registered with Claude Code"
fi

if has codex && ! codex mcp get uidotsh &>/dev/null; then
  codex mcp add uidotsh --url "https://ui.sh/mcp?agent=codex" \
    --bearer-token-env-var UIDOTSH_TOKEN
  log_item "Registered with Codex"
fi

log_success "ui.sh MCP server registered"
