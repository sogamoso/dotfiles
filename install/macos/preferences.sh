#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Setting macOS preferences..."

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

# Accessibility: disable UI transparency (requires Full Disk Access — skipped if denied)
defaults write com.apple.universalaccess reduceTransparency -bool true 2>/dev/null || \
  log_warn "Could not set reduceTransparency — grant Full Disk Access to Terminal and rerun"

# Menu bar: auto-hide
osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true'

# Dock: clear pinned apps, position, size, autohide
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 43

# Screensaver: 5 min idle, lock immediately
defaults -currentHost write com.apple.screensaver idleTime -int 300
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Display sleep: 30 min idle
sudo pmset -a displaysleep 30

if system_profiler SPHardwareDataType 2>/dev/null | grep -q "Mac mini"; then
  # Mac mini: never sleep (desktop, always on AC), restart after power failure
  sudo pmset -a sleep 0 disksleep 0 autorestart 1
else
  # Mac laptop: wake at 8 AM weekdays (no forced 7 PM sleep — handled by idle-aware agent)
  sudo pmset repeat wakeorpoweron MTWRF 08:00:00
fi

killall Dock

# Load work hours agents on laptops only (Mac mini stays awake via pmset)
if ! system_profiler SPHardwareDataType 2>/dev/null | grep -q "Mac mini"; then
  for label in com.sogamoso.workhours.caffeinate com.sogamoso.workhours.caffeinate-run com.sogamoso.workhours.caffeinate-watch com.sogamoso.workhours.sleep-if-idle; do
    plist="$HOME/Library/LaunchAgents/$label.plist"
    launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$plist"
    launchctl enable "gui/$(id -u)/$label"
  done
fi

log_success "macOS preferences set"
