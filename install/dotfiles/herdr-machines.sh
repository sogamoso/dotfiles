#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Saves the Mac mini as a herdr machine on every other host, so its workspaces
# and agents show in the same herdr window: long-running agents go there, and
# keep running when this machine sleeps or shuts down. The target is the
# mac-mini host from the stowed ~/.ssh/config, reached through Tailscale SSH.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/herdr-plugins.sh"

command -v herdr >/dev/null || exit 0

# The mini itself has nothing to add: its agents are Local there
on_herdr_machine_host && exit 0

log_heading "Saving herdr machines..."

if herdr machine list --json 2>/dev/null |
  jq -e --arg host "$HERDR_MACHINE" '.[] | select(.label == $host or .target == $host or .ssh_target == $host)' >/dev/null 2>&1; then
  log_item "$HERDR_MACHINE (saved)"
elif herdr machine add "$HERDR_MACHINE" </dev/null >/dev/null 2>&1; then
  log_success "$HERDR_MACHINE saved"
else
  # Without a terminal, setup can't answer a Tailscale check or approve a herdr
  # install on the mini, so it stops instead of guessing
  log_warn "Could not save $HERDR_MACHINE; run: herdr machine add $HERDR_MACHINE"
fi
