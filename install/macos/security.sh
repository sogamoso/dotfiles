#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Configuring security..."

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

# Full Disk Access is required to write certain system preferences (e.g. universalaccess)
if ! cat /Library/Application\ Support/com.apple.TCC/TCC.db &>/dev/null; then
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
  echo -e "\n! Grant Full Disk Access to Terminal in the System Settings pane that just opened"
  read -r -p "  Press Enter once done..."
fi
