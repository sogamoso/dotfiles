#!/usr/bin/env bash
# Moves stale app bundles out of the Caskroom.
#
# A cask's Caskroom entry for an installed app is a symlink to
# /Applications. When an upgrade is cut short (Homebrew autoupdate running
# while the app is open, or an app that updated itself mid-move), Homebrew can
# leave a real copy of the app there instead. Every later upgrade then moves
# /Applications' copy back into the Caskroom to uninstall it, finds that path
# taken and fails with "It seems there is already an App at ...". A real
# bundle there is never what Homebrew expects while /Applications has the app,
# so it goes to the Trash, recoverable, rather than being deleted.
#
# Sourced by install/macos/brew.sh and by `dotfiles brew`, before `brew bundle`.

brew_clear_stale_apps() {
  local app name stamp
  stamp=$(date +%s)
  for app in "$(brew --prefix)"/Caskroom/*/*/*.app; do
    name=${app##*/}
    [[ -d $app && ! -L $app && -d "/Applications/$name" ]] || continue
    # Callers run under set -e, and a failed move must not skip what follows
    # brew bundle (the firewall steps, in `dotfiles brew`)
    if mv "$app" "$HOME/.Trash/${name%.app} (Caskroom $stamp).app"; then
      echo "==> Moved a stale $app to the Trash"
    else
      echo "==> Couldn't move a stale $app to the Trash; its cask may fail to upgrade"
    fi
  done
  return 0
}
