#!/usr/bin/env bash
# Trusts every tap the Brewfile declares.
#
# Homebrew 6+ refuses to load formulae and casks from non-official taps until
# they're trusted, and the refusal surfaces far from the cause: `brew cleanup`
# dies on the first cask from an untrusted tap. Trust is per machine, so one
# bootstrapped before Homebrew added the check never gets it unless something
# re-runs this. `brew trust` only records names, so the tap doesn't need to be
# present yet, and re-trusting is a no-op.
#
# Sourced by install/macos/brew.sh before the first `brew bundle`, and by
# `dotfiles brew` so existing machines catch up on the next update.

brew_trust_taps() {
  local brewfile=$1 tap
  brew trust --help &>/dev/null || return 0
  while IFS= read -r tap; do
    brew trust "$tap" >/dev/null
  done < <(grep -E '^tap "' "$brewfile" | sed -E 's/^tap "([^"]+)".*/\1/')
}
