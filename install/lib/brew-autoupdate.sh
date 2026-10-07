#!/usr/bin/env bash
# Keeps brew autoupdate running daily with the flags below.
#
# Dependencies are upgraded too: with --leaves-only they only moved when
# something above them did, and fell months behind.
#
# A running agent keeps whatever flags it was started with, so the flags it got
# are recorded and a change to them restarts it. Checking only that it runs left
# machines set up before a change on the old flags indefinitely. The restart
# opens a GUI sudo prompt, so it only happens when something is actually off.
#
# Sourced by install/macos/brew.sh and by `dotfiles brew`, so existing machines
# catch up on the next update rather than the next bootstrap.

BREW_AUTOUPDATE_ARGS=(86400 --ac-only --upgrade --cleanup --immediate --sudo)

# Returns non-zero when the agent had to be (re)started and that failed.
brew_autoupdate_ensure() {
  local state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/brew-autoupdate.args"
  if brew autoupdate status 2>/dev/null | grep -q "Autoupdate is installed and running" &&
    [[ "$(cat "$state" 2>/dev/null)" == "${BREW_AUTOUPDATE_ARGS[*]}" ]]; then
    return 0
  fi
  brew autoupdate delete 2>/dev/null || true
  # --sudo needs pinentry-mac, installed via the Brewfile.
  brew autoupdate start "${BREW_AUTOUPDATE_ARGS[@]}" || return 1
  mkdir -p "$(dirname "$state")"
  echo "${BREW_AUTOUPDATE_ARGS[*]}" >"$state"
}
