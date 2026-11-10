#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Saves the Mac mini as a herdr machine on every other host, so its workspaces
# and agents show in the same herdr window: long-running agents go there, and
# keep running when this machine sleeps or shuts down. The target is the
# mac-mini host from the stowed ~/.ssh/config, reached through Tailscale SSH.
# Where the Herdr app is installed, its core (hc) saves the mini too, so the
# app's sidebar shows it; that one installs herdr-core on the mini when it
# has none, as Herdr's own Add machine does.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/herdr-plugins.sh"

command -v herdr >/dev/null || command -v hc >/dev/null || exit 0

# The mini itself has nothing to add: its agents are Local there
on_herdr_machine_host && exit 0

log_heading "Saving herdr machines..."

if command -v herdr >/dev/null; then
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
fi

if command -v hc >/dev/null; then
  # hc names a machine after its ssh host unless told otherwise
  if hc machine ls --json 2>/dev/null |
    jq -e --arg host "$HERDR_MACHINE" '.machines[] | select((.name // .target // "" | tostring) == $host)' >/dev/null 2>&1; then
    log_item "$HERDR_MACHINE (saved in herdr-core)"
  elif hc machine add "$HERDR_MACHINE" --install </dev/null >/dev/null 2>&1; then
    log_success "$HERDR_MACHINE saved in herdr-core"
  else
    log_warn "Could not save $HERDR_MACHINE in herdr-core; run: hc machine add $HERDR_MACHINE"
  fi
fi
