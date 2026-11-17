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

# Rex has no fixed download link, only its Sparkle feed, which lists builds
# newest first. The preview channel ships the app as "Rex Beta"; if that name
# changes the install is refused, and dotfiles doctor checks the same name.
REX_APPCAST="https://blob.superlogical.com/public/rex-app/preview/appcast.xml"
REX_APP="Rex Beta.app"
# Superlogical, Inc.'s Developer ID. A DMG signed by anyone else is refused.
REX_TEAM="AG92C3PT77"

install_rex() (
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-rex.XXXXXX")"
  mnt="$tmp/mnt"
  trap 'hdiutil detach "$mnt" -quiet 2>/dev/null || true; rm -rf "$tmp"' EXIT

  dmg_url="$(curl -fsSL "$REX_APPCAST" | sed -n 's/.*<enclosure url="\([^"]*\.dmg\)".*/\1/p' | head -n 1)" || return 1
  [[ $dmg_url == "https://blob.superlogical.com/public/rex-app/"* ]] || return 1

  curl -fsSL -o "$tmp/Rex.dmg" "$dmg_url" || return 1
  hdiutil attach -nobrowse -readonly -mountpoint "$mnt" "$tmp/Rex.dmg" -quiet || return 1
  app="$mnt/$REX_APP"
  if [[ ! -d $app ]]; then
    log_warn "The Rex DMG has no $REX_APP; update REX_APP in install/macos/apps.sh and dotfiles doctor"
    return 1
  fi

  team="$(codesign -dv "$app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
  if [[ $team != "$REX_TEAM" ]] || ! spctl -a -t exec "$app" 2>/dev/null; then
    log_warn "$REX_APP failed its signature check (team: ${team:-none}); not installing"
    return 1
  fi
  ditto "$app" "/Applications/$REX_APP"
)

if [[ ! -d "/Applications/$REX_APP" ]]; then
  log_heading "Installing Rex..."
  if install_rex; then
    log_success "Rex installed"
  else
    log_warn "Could not install Rex — download it from $REX_APPCAST"
  fi
fi
