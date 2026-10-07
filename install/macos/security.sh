#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log_heading "Configuring security..."

# Keep Remote Login (macOS's SSH server) off: SSH between machines goes through
# Tailscale SSH, which only answers on the tailnet, while sshd would listen on
# every network a laptop joins. -w makes it stick across reboots.
if launchctl print system/com.openssh.sshd &>/dev/null; then
  sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
fi

# Harden sshd anyway, in case Remote Login gets turned back on by hand
if ! diff -q "$REPO_DIR/etc/ssh/sshd_config.d/hardening.conf" /etc/ssh/sshd_config.d/hardening.conf &>/dev/null; then
  sudo mkdir -p /etc/ssh/sshd_config.d
  sudo install -m 0644 "$REPO_DIR/etc/ssh/sshd_config.d/hardening.conf" /etc/ssh/sshd_config.d/hardening.conf
fi

# Enable macOS firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Full Disk Access reminder (TCC db access is blocked in modern macOS)
log_warn "Grant Full Disk Access to Terminal/Ghostty if needed:"
log_info "     System Settings → Privacy & Security → Full Disk Access → Enable Terminal"
