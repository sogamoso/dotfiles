#!/usr/bin/env bash
# Sourced by install/dotfiles/stow.sh and `dotfiles doctor` — never run directly.

# The stow packages this OS gets. Omarchy is bash-based and ships its own
# alias/function layer, so the zsh package is macOS only. Its bash counterpart
# lives in the linux package.
STOW_PACKAGES=(agents claude editorconfig git herdr mise nvim ruby ssh)
case "$(uname -s)" in
  Darwin) STOW_PACKAGES+=(zsh macos) ;;
  Linux)  STOW_PACKAGES+=(linux) ;;
esac
