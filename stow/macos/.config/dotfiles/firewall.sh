#!/usr/bin/env bash
# Keep the Homebrew daemons that accept connections allowed through the macOS
# firewall: tailscaled for direct (non-relayed) Tailscale links, mosh-server
# for mosh sessions over the tailnet.
#
# Usage:
#   firewall.sh                   allow the current binaries and restart a
#                                 tailscaled left on an old one (sudo if needed)
#   firewall.sh --check           only report; notify when a binary is blocked
#   firewall.sh --check --quiet   only report (for dotfiles doctor)
#
# Both are ad hoc signed, so the firewall's permission is tied to the exact
# binary, and an upgrade lands a new one in a new Cellar path that starts out
# blocked. brew autoupdate upgrades in the background without a password, so
# a daily --check (com.sogamoso.firewall-check) says when `dotfiles brew` is
# needed to re-allow them.
set -euo pipefail

FW=/usr/libexec/ApplicationFirewall/socketfilterfw
GROUP_ID="dotfiles-firewall"
BINARIES=(
  /opt/homebrew/opt/tailscale/bin/tailscaled
  /opt/homebrew/opt/mosh/bin/mosh-server
)
TAILSCALED_LABEL=sh.brew.tailscale

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
    as_root launchctl kickstart -k "system/$TAILSCALED_LABEL"
    echo "Restarted tailscaled on the upgraded version"
    changed=1
  fi

  (( changed )) || echo "Firewall already allows the current tailscaled and mosh-server"
}

case "${1:-}" in
  --check) check "${2:-}" ;;
  "") allow ;;
  *) echo "Usage: firewall.sh [--check [--quiet]]" >&2; exit 1 ;;
esac
