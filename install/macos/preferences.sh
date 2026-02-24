#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Desktop wallpaper
osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "'"$REPO_DIR/assets/desktop.png"'"'

# Screensaver: photo slideshow from assets folder
defaults -currentHost write com.apple.screensaver moduleDict -dict \
  moduleName -string "iLifeSlideshows" \
  path -string "/System/Library/Frameworks/ScreenSaver.framework/PlugIns/iLifeSlideshows.appex" \
  type -int 0
defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows styleKey -string "Classic"
defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows selectedFolderPath -string "$REPO_DIR/assets"
defaults -currentHost write com.apple.ScreenSaver.iLifeSlideShows selectedMediaGroup -string "selectedFolderPath"

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

killall ControlCenter
