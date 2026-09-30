#!/usr/bin/env bash
set -euo pipefail

# Codex launched from ChatGPT.app inherits the launchd GUI session environment,
# not a shell's, so the token the shell supplements export never reaches it.
# Publish it into the session at login instead.
#
# This is a deliberate widening: launchctl setenv makes the value readable by
# every GUI process in the login session via `launchctl getenv`, where the file
# it comes from is 0600. Acceptable for a personal ui.sh token, not a pattern to
# copy for anything with a blast radius beyond this account.
TOKEN_ENV_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/uidotsh.env"
[[ -r $TOKEN_ENV_FILE ]] || exit 0

source "$TOKEN_ENV_FILE"
[[ -n ${UIDOTSH_TOKEN:-} ]] || exit 0

launchctl setenv UIDOTSH_TOKEN "$UIDOTSH_TOKEN"
