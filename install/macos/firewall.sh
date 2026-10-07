#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Let the Homebrew daemons that accept connections through the macOS firewall:
# tailscaled for direct (non-relayed) Tailscale links, mosh-server for mosh
# sessions over the tailnet. Both are ad hoc signed, so the firewall's
# permission is tied to the exact binary and an upgrade lands a new one in a
# new Cellar path that starts out blocked. Each run re-allows the current
# binaries and drops entries for older versions, and only asks for sudo when
# something actually changed.

FW=/usr/libexec/ApplicationFirewall/socketfilterfw
BINARIES=(
  /opt/homebrew/opt/tailscale/bin/tailscaled
  /opt/homebrew/opt/mosh/bin/mosh-server
)

log_heading "Allowing Homebrew daemons through the firewall..."

listed() {
  "$FW" --listapps | sed -nE 's/^[0-9]+ : (.*[^ ]) *$/\1/p'
}

changed=0
for link in "${BINARIES[@]}"; do
  [[ -e $link ]] || continue
  real="$(readlink -f "$link")"
  name="$(basename "$real")"

  # Older versions, plus any entry added by a symlinked path rather than the
  # binary itself: both name the same program and only the current one counts.
  while IFS= read -r entry; do
    [[ $entry == "$real" ]] && continue
    sudo "$FW" --remove "$entry" >/dev/null
    log_item "Removed stale firewall entry $entry"
    changed=1
  done < <(listed | grep -E "^/opt/homebrew/.*/$name$" || true)

  if ! listed | grep -qxF "$real"; then
    sudo "$FW" --add "$real" >/dev/null
    sudo "$FW" --unblockapp "$real" >/dev/null
    log_item "Allowed $real"
    changed=1
  fi
done

if (( changed )); then
  log_success "Firewall updated"
else
  log_success "Firewall already allows the current binaries"
fi
