#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" # Make brew available in THIS shell
fi

command -v brew >/dev/null 2>&1 || { echo "brew not found on PATH after install" >&2; exit 1; }

# Install new casks and formulae
brew bundle --file "$REPO_DIR/Brewfile"

# Autoupdate now and once a week
brew autoupdate delete >/dev/null 2>&1 || true
brew autoupdate start 604800 --ac-only --upgrade --cleanup --leaves-only --immediate --sudo

# Enable Remote Login (SSH server)
if ! launchctl print system/com.openssh.sshd &>/dev/null; then
  sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
fi

# Harden sshd
if ! diff -q "$REPO_DIR/etc/ssh/sshd_config.d/hardening.conf" /etc/ssh/sshd_config.d/hardening.conf &>/dev/null; then
  sudo mkdir -p /etc/ssh/sshd_config.d
  sudo install -m 0644 "$REPO_DIR/etc/ssh/sshd_config.d/hardening.conf" /etc/ssh/sshd_config.d/hardening.conf
fi

# Enable macOS firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# zsh-you-should-use
PLUGIN_DIR="$HOME/.config/zsh/plugins/zsh-you-should-use"
mkdir -p "$PLUGIN_DIR"
ln -sf "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" "$PLUGIN_DIR/you-should-use.plugin.zsh"

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
killall Dock
killall ControlCenter
