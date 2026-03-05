#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Setting macOS preferences..."

# Dark mode
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# Scroll direction: non-natural
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Disable click desktop to reveal
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# 24-hour clock
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# Keyboard repeat speed
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

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

# Menu bar: auto-hide on hover (both keys required on macOS 26)
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write com.apple.controlcenter AutoHideMenuBarOption -int 2
killall SystemUIServer ControlCenter 2>/dev/null; true

# Dock: position, size, autohide, unpin all apps, disable workspace auto-rearrange, switch to space with open windows
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 43
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock workspaces-auto-swoosh -bool true

# Dock: disable hot corners
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
killall Dock
