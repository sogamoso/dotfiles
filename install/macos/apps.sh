#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Apps Homebrew has no cask for. Each is skipped once installed, since it
# updates itself from then on.

WABI_DMG="https://desktop-updates.wabi.ai/download/Wabi-mac-arm64.dmg"
# Wabi, Inc.'s Developer ID. A DMG signed by anyone else is refused.
WABI_TEAM="J4Q32LA8N4"

# A subshell, so its EXIT trap unmounts and cleans up on every path out.
install_wabi() (
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-wabi.XXXXXX")"
  mnt="$tmp/mnt"
  trap 'hdiutil detach "$mnt" -quiet 2>/dev/null || true; rm -rf "$tmp"' EXIT

  curl -fsSL -o "$tmp/Wabi.dmg" "$WABI_DMG" || return 1
  hdiutil attach -nobrowse -readonly -mountpoint "$mnt" "$tmp/Wabi.dmg" -quiet || return 1
  app="$mnt/Wabi.app"
  [[ -d $app ]] || return 1

  team="$(codesign -dv "$app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
  if [[ $team != "$WABI_TEAM" ]] || ! spctl -a -t exec "$app" 2>/dev/null; then
    log_warn "Wabi.app failed its signature check (team: ${team:-none}); not installing"
    return 1
  fi
  ditto "$app" "/Applications/Wabi.app"
)

if [[ ! -d "/Applications/Wabi.app" ]]; then
  log_heading "Installing Wabi..."
  if install_wabi; then
    log_success "Wabi installed"
  else
    log_warn "Could not install Wabi — download it from https://wabi.ai/download"
  fi
fi
