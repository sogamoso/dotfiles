#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "\n==> Configuring security..."
sudo echo "✓ Granted"

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
