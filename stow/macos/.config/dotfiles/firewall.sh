#!/usr/bin/env bash
# Keep the Homebrew daemons that accept connections allowed through the macOS
# firewall: tailscaled for direct (non-relayed) Tailscale links, mosh-server
# for mosh sessions over the tailnet.
#
# Usage:
#   firewall.sh                   allow the current binaries and restart a
#                                 tailscaled left on an old one (sudo if needed)
#   firewall.sh --install         install the root LaunchDaemon that does that
#                                 by itself after every upgrade
#   firewall.sh --check           only report; notify when a binary is blocked
#   firewall.sh --check --quiet   only report (for dotfiles doctor)
#
# Both binaries are ad hoc signed, so the firewall's permission is tied to the
# exact binary, and an upgrade lands a new one in a new Cellar path that starts
# out blocked. brew autoupdate upgrades in the background, so a root
# LaunchDaemon (com.sogamoso.firewall-sync) runs this whenever the Cellar
# changes. It runs a root-owned copy in /usr/local/libexec/dotfiles, never this
# user-writable file, and as root it only calls system binaries.
#
# Written for /bin/bash 3.2, which the LaunchDaemon uses.
set -euo pipefail

FW=/usr/libexec/ApplicationFirewall/socketfilterfw
GROUP_ID="dotfiles-firewall"
BINARIES=(
  /opt/homebrew/opt/tailscale/bin/tailscaled
  /opt/homebrew/opt/mosh/bin/mosh-server
)
# Homebrew 7 labels services sh.brew.*, but a daemon started by an older brew
# keeps its homebrew.mxcl.* label until it's started again.
TAILSCALED_LABELS=(sh.brew.tailscale homebrew.mxcl.tailscale)
DAEMON_LABEL=com.sogamoso.firewall-sync
DAEMON_SCRIPT=/usr/local/libexec/dotfiles/firewall.sh
DAEMON_PLIST=/Library/LaunchDaemons/$DAEMON_LABEL.plist

as_root() {
  if (( EUID == 0 )); then "$@"; else sudo "$@"; fi
}

listed() {
  "$FW" --listapps | sed -nE 's/^[0-9]+ : (.*[^ ]) *$/\1/p'
}

# Whether the running tailscaled predates the installed version: brew upgrades
# don't restart services, so the old one keeps running until the next reboot.
# Comparing start time with when the version folder was created works without
# root and without running anything from Homebrew.
tailscaled_outdated() {
  local pid started real installed
  pid=$(pgrep -x tailscaled | head -1) || return 1
  started=$(ps -o lstart= -p "$pid" | sed 's/ *$//')
  started=$(LC_ALL=C date -j -f "%a %b %e %T %Y" "$started" +%s 2>/dev/null) || return 1
  real="$(readlink -f "${BINARIES[0]}")" || return 1
  installed=$(stat -f %B "${real%/bin/tailscaled}") || return 1
  (( started < installed ))
}

check() {
  local link blocked=()
  for link in "${BINARIES[@]}"; do
    [[ -e $link ]] || continue
    listed | grep -qxF "$(readlink -f "$link")" || blocked+=("$(basename "$link")")
  done
  if (( ${#blocked[@]} == 0 )); then
    echo "Firewall allows the current tailscaled and mosh-server"
    return 0
  fi
  echo "Blocked by the firewall: ${blocked[*]}"
  if [[ ${1:-} != "--quiet" && -r $HOME/.config/dotfiles/lib/notify.sh ]]; then
    source "$HOME/.config/dotfiles/lib/notify.sh"
    notify "Firewall blocks ${blocked[*]}" "Run dotfiles brew to allow the upgraded binaries"
  fi
  return 1
}

allow() {
  local link real name entry changed=0
  for link in "${BINARIES[@]}"; do
    [[ -e $link ]] || continue
    real="$(readlink -f "$link")"
    name="$(basename "$real")"

    # Older versions, plus any entry added by a symlinked path rather than the
    # binary itself: both name the same program and only the current one counts.
    while IFS= read -r entry; do
      [[ $entry == "$real" ]] && continue
      as_root "$FW" --remove "$entry" >/dev/null
      echo "Removed stale firewall entry $entry"
      changed=1
    done < <(listed | grep -E "^/opt/homebrew/.*/$name$" || true)

    if ! listed | grep -qxF "$real"; then
      as_root "$FW" --add "$real" >/dev/null
      as_root "$FW" --unblockapp "$real" >/dev/null
      echo "Allowed $real"
      changed=1
    fi
  done

  if tailscaled_outdated; then
    local label restarted=0
    for label in "${TAILSCALED_LABELS[@]}"; do
      launchctl print "system/$label" >/dev/null 2>&1 || continue
      as_root launchctl kickstart -k "system/$label"
      echo "Restarted tailscaled on the upgraded version"
      changed=1 restarted=1
      break
    done
    (( restarted )) || echo "tailscaled runs an old binary, but no Tailscale LaunchDaemon was found to restart" >&2
  fi

  (( changed )) || echo "Firewall already allows the current tailscaled and mosh-server"
}

daemon_plist() {
  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$DAEMON_LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$DAEMON_SCRIPT</string>
    <string>--daemon</string>
  </array>

  <!-- An upgrade adds a version folder here and brew's cleanup removes the old one -->
  <key>WatchPaths</key>
  <array>
    <string>/opt/homebrew/Cellar/tailscale</string>
    <string>/opt/homebrew/Cellar/mosh</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>9</integer>
    <key>Minute</key><integer>30</integer>
  </dict>

  <key>StandardOutPath</key>
  <string>/var/log/$DAEMON_LABEL.log</string>
  <key>StandardErrorPath</key>
  <string>/var/log/$DAEMON_LABEL.log</string>
</dict>
</plist>
EOF
}

# Copy this script somewhere only root can write and load the LaunchDaemon.
# A no-op, without sudo, when both copies already match and it's loaded.
install_daemon() {
  local self plist_tmp
  self="$(readlink -f "${BASH_SOURCE[0]}")"
  plist_tmp="$(mktemp)"
  daemon_plist >"$plist_tmp"
  if cmp -s "$self" "$DAEMON_SCRIPT" && cmp -s "$plist_tmp" "$DAEMON_PLIST" &&
    launchctl print "system/$DAEMON_LABEL" >/dev/null 2>&1; then
    rm -f "$plist_tmp"
    echo "Firewall sync daemon is up to date"
    return 0
  fi
  as_root mkdir -p "$(dirname "$DAEMON_SCRIPT")"
  as_root chown root:wheel "$(dirname "$DAEMON_SCRIPT")"
  as_root chmod 755 "$(dirname "$DAEMON_SCRIPT")"
  as_root install -o root -g wheel -m 755 "$self" "$DAEMON_SCRIPT"
  as_root install -o root -g wheel -m 644 "$plist_tmp" "$DAEMON_PLIST"
  rm -f "$plist_tmp"
  as_root launchctl bootout "system/$DAEMON_LABEL" 2>/dev/null || true
  as_root launchctl bootstrap system "$DAEMON_PLIST"
  echo "Installed the firewall sync daemon"
}

case "${1:-}" in
  --check) check "${2:-}" ;;
  --install) install_daemon ;;
  # Let brew finish linking and cleaning up before looking at the result
  --daemon) sleep 30; echo "$(date '+%F %T') sync"; allow ;;
  "") allow ;;
  *) echo "Usage: firewall.sh [--install | --check [--quiet]]" >&2; exit 1 ;;
esac
