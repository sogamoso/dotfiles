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

# Accessibility: disable UI transparency (requires Full Disk Access — skipped if denied)
defaults write com.apple.universalaccess reduceTransparency -bool true 2>/dev/null || \
  echo "⚠ Could not set reduceTransparency — grant Full Disk Access to Terminal and rerun"

# Menu bar: auto-hide on hover (both keys required on macOS 26)
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write com.apple.controlcenter AutoHideMenuBarOption -int 2

# Menu bar: item visibility
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible BentoBox" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC WiFi" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC AudioVideoModule" -bool true
killall SystemUIServer ControlCenter 2>/dev/null; true

# Dock: position, size, autohide, instant show/hide, dwindle animation, unpin all apps
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock tilesize -int 43
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock workspaces-auto-swoosh -bool true
defaults write com.apple.dock workspaces-swoosh-animation-off -bool true

# Dock: disable hot corners and tile-by-edge-drag (Aerospace owns tiling)
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
killall Dock

# Disable Mission Control keyboard shortcuts (conflict with Aerospace ctrl-* after Karabiner swap)
# 32=Mission Control, 34=Show Desktop, 118-126=Switch to Space 1-9
for id in 32 34 118 119 120 121 122 123 124 125 126; do
  /usr/libexec/PlistBuddy \
    -c "Set :AppleSymbolicHotKeys:${id}:enabled false" \
    ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true
done

# Disable input source switcher Cmd+Space (60/61) — reassign manually to a function key
# System Settings → Keyboard → Keyboard Shortcuts → Input Sources
/usr/libexec/PlistBuddy \
  -c "Set :AppleSymbolicHotKeys:60:enabled false" \
  ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true
/usr/libexec/PlistBuddy \
  -c "Set :AppleSymbolicHotKeys:61:enabled false" \
  ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true

# Disable Spotlight Cmd+Space (64) — Raycast takes that slot
# After Karabiner swap, physical Ctrl+Space sends Cmd+Space to macOS → would open Spotlight
/usr/libexec/PlistBuddy \
  -c "Set :AppleSymbolicHotKeys:64:enabled false" \
  ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true
/usr/libexec/PlistBuddy \
  -c "Set :AppleSymbolicHotKeys:65:enabled false" \
  ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true

# Apply symbolic hotkey changes
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
