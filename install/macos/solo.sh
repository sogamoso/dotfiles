#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Installing Solo..."

if [[ -d "/Applications/Solo.app" ]]; then
  log_success "Solo already installed (auto-updates from app)"
  exit 0
fi

SOLO_URL=$(curl -s https://soloterm.com/download \
  | grep -oE 'https://releases\.soloterm\.com/darwin/universal/Solo-[0-9.]+\.dmg' \
  | head -1)

if [[ -z $SOLO_URL ]]; then
  log_warn "Could not find Solo DMG URL on soloterm.com/download"
  exit 1
fi

SOLO_DMG=$(mktemp -t Solo-XXXXXX.dmg)
curl -fL "$SOLO_URL" -o "$SOLO_DMG"

MOUNT_POINT=$(mktemp -d -t solo-mount-XXXXXX)
hdiutil attach -nobrowse -quiet -mountpoint "$MOUNT_POINT" "$SOLO_DMG"
cp -R "$MOUNT_POINT/Solo.app" /Applications/
hdiutil detach -quiet "$MOUNT_POINT"
rm -f "$SOLO_DMG"
rmdir "$MOUNT_POINT" 2>/dev/null || true

log_success "Solo installed from $(basename "$SOLO_URL")"
