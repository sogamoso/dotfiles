#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Setting macOS preferences..."

# Desktop wallpaper
osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "'"$REPO_DIR/assets/desktop.png"'"'

# Screensaver: photo slideshow from assets folder
defaults -currentHost write com.apple.screensaver moduleDict -dict \
  moduleName -string "iLifeSlideshows" \
  path -string "/System/Library/Frameworks/ScreenSaver.framework/PlugIns/iLifeSlideshows.appex" \
  type -int 0
defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows styleKey -string "Classic"
defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows selectedFolderPath -string "$REPO_DIR/assets/screensaver"
defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows selectedMediaGroup -string "selectedFolderPath"
defaults -currentHost write com.apple.screensaver showClock -bool true

# Accessibility: disable UI transparency (opaque menu bar/backgrounds)
defaults write com.apple.universalaccess reduceTransparency -bool true
killall SystemUIServer || true

# Menu bar: tighter icon spacing
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 10

# Menu bar: show only Bluetooth, WiFi, and Clock
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool false
defaults write com.apple.controlcenter "NSStatusItem VisibleCC WiFi" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Clock" -bool true
killall ControlCenter || true

# Dock: unpin all apps
defaults write com.apple.dock persistent-apps -array
killall Dock || true

# Login items
add_login_item() {
  local path="$1" name
  name="$(basename "$path" .app)"
  osascript -e "tell application \"System Events\" to get the name of every login item" | grep -qw "$name" || \
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$path\", hidden:false}"
}
add_login_item "/Applications/Hammerspoon.app"
add_login_item "/Applications/Rectangle Pro.app"
