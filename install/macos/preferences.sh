#!/usr/bin/env bash
set -euo pipefail

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
