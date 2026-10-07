#!/usr/bin/env bash
# Keep the Homebrew daemons that accept connections allowed through the macOS
# firewall: tailscaled for direct (non-relayed) Tailscale links, mosh-server
# for mosh sessions over the tailnet.
#
# Usage:
#   firewall.sh           allow the current binaries (asks for sudo only if needed)
#   firewall.sh --check   only report; notify when a binary is blocked
#   firewall.sh --check --quiet   only report (for dotfiles doctor)
#
# Both are ad hoc signed, so the firewall's permission is tied to the exact
# binary, and an upgrade lands a new one in a new Cellar path that starts out
# blocked. brew autoupdate upgrades in the background without a password, so
# a daily --check (com.sogamoso.firewall-check) says when `dotfiles update` is
# needed to re-allow them.
set -euo pipefail

FW=/usr/libexec/ApplicationFirewall/socketfilterfw
GROUP_ID="dotfiles-firewall"
BINARIES=(
  /opt/homebrew/opt/tailscale/bin/tailscaled
  /opt/homebrew/opt/mosh/bin/mosh-server
)

source "$HOME/.config/dotfiles/lib/notify.sh"

listed() {
  "$FW" --listapps | sed -nE 's/^[0-9]+ : (.*[^ ]) *$/\1/p'
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
  [[ ${1:-} == "--quiet" ]] ||
    notify "Firewall blocks ${blocked[*]}" "Run dotfiles update to allow the upgraded binaries"
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
      sudo "$FW" --remove "$entry" >/dev/null
      echo "Removed stale firewall entry $entry"
      changed=1
    done < <(listed | grep -E "^/opt/homebrew/.*/$name$" || true)

    if ! listed | grep -qxF "$real"; then
      sudo "$FW" --add "$real" >/dev/null
      sudo "$FW" --unblockapp "$real" >/dev/null
      echo "Allowed $real"
      changed=1
    fi
  done
  (( changed )) || echo "Firewall already allows the current tailscaled and mosh-server"
}

case "${1:-}" in
  --check) check "${2:-}" ;;
  "") allow ;;
  *) echo "Usage: firewall.sh [--check [--quiet]]" >&2; exit 1 ;;
esac
