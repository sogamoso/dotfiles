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

# Accessibility: disable UI transparency
defaults write com.apple.universalaccess reduceTransparency -bool true

# Menu bar: auto-hide (accessible on hover, reserved space for SketchyBar)
defaults write NSGlobalDomain _HIHideMenuBar -bool false
defaults write com.apple.dock autohide-menu-bar -bool true
killall SystemUIServer

# Dock: unpin all apps, disable workspace auto-rearrange, switch to space with open windows
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock workspaces-auto-swoosh -bool true

# Dock: disable hot corners
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
killall Dock
