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

# Fn key: change input source (0=nothing, 1=input source, 2=emoji, 3=dictation)
defaults write com.apple.HIToolbox AppleFnUsageType -int 1

# Desktop wallpaper
osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "'"$REPO_DIR/assets/desktop.png"'"'

# Accessibility: disable UI transparency (requires Full Disk Access — skipped if denied)
defaults write com.apple.universalaccess reduceTransparency -bool true 2>/dev/null || \
  echo "⚠ Could not set reduceTransparency — grant Full Disk Access to Terminal and rerun"

# Menu bar: auto-hide on hover (NOTE: Control Center keys change frequently with macOS versions)
# These keys are fragile and may need updating on new macOS releases
# defaults write NSGlobalDomain _HIHideMenuBar -bool true
# defaults write com.apple.controlcenter AutoHideMenuBarOption -int 2

# Dock: position, size, autohide (stable keys)
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 43
killall Dock

echo "✓ macOS preferences set"
