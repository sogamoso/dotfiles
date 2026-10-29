#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# herdr's agent integrations: a SessionStart hook in each agent that tells herdr
# the session it runs, so a herdr server restart, a reboot included, resumes the
# conversation in its pane instead of leaving a bare shell. Without one herdr
# still sees the agent, by reading its screen, but has nothing to resume. Each
# hook script no-ops outside a herdr pane. Rerun on every `dotfiles reload`, so
# a herdr upgrade's newer hook versions land; reinstalling changes nothing
# otherwise.

command -v herdr >/dev/null || exit 0

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/herdr-plugins.sh"

log_heading "Installing herdr agent integrations..."

# herdr refuses an integration whose agent config directory is missing, and
# cursor-agent only creates ~/.cursor on its first run. It's a lazy mise tool, so
# not even `mise install` fetches it, and on a machine where it has never run
# the cursor hook would fail every time. The hook no-ops until the agent runs.
mkdir -p "$HOME/.cursor"

failed=""
for agent in "${HERDR_INTEGRATIONS[@]}"; do
  if [[ $agent == "claude" ]]; then
    # The installer would also add the hook to ~/.claude/settings.json, which is
    # stowed from this repo and shared with Omarchy, under this machine's
    # absolute path, and add it again on every run. The stowed file carries it
    # through $HOME instead, so only the script is taken from a scratch install.
    scratch=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-herdr-claude.XXXXXX")
    mkdir -p "$scratch/.claude" "$HOME/.claude/hooks"
    echo '{}' >"$scratch/.claude/settings.json"
    if HOME="$scratch" herdr integration install claude >/dev/null 2>&1 &&
      install -m 0755 "$scratch/.claude/hooks/herdr-agent-state.sh" "$HOME/.claude/hooks/herdr-agent-state.sh"; then
      log_item "$agent"
    else
      failed+=" $agent"
    fi
    rm -rf "$scratch"
  elif herdr integration install "$agent" >/dev/null 2>&1; then
    log_item "$agent"
  else
    failed+=" $agent"
  fi
done

if [[ -n $failed ]]; then
  log_warn "Could not install:$failed"
else
  log_success "herdr agent integrations installed"
fi
