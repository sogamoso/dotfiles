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

# Full Disk Access reminder (TCC db access is blocked in modern macOS)
echo -e "\n⚠ Grant Full Disk Access to Terminal/Ghostty if needed:"
echo "  System Settings → Privacy & Security → Full Disk Access → Enable Terminal"
