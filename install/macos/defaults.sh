#!/usr/bin/env bash
set -euo pipefail

# macOS defaults override
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 43
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

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

killall Dock
killall ControlCenter
