alias ts='tailscale'
alias tsu='tailscale up --ssh'
alias tsd='tailscale down'

tss() {
  tailscale status "$@"
}

tse() {
  tss --json | jq -r ".Peer[] | select(.ExitNode == true) | .DNSName"
}

tsel() {
  local country="${1-}"

  if [[ -z "$country" ]]; then
    tailscale exit-node list
  else
    tailscale exit-node list -filter="$country"
  fi
}

# Homebrew's tailscaled on macOS accepts --exit-node but never routes through
# it, and the saved setting then makes `tailscale up --ssh` (tsu) fail until
# it's cleared. Refuse instead of saving a setting that does nothing.
ts_no_exit_nodes() {
  echo "Exit nodes don't work with Homebrew's tailscaled on macOS; nothing changed" >&2
  return 1
}

tsec() {
  ts_no_exit_nodes || return 1
  local node="${1-}"
  local usage="Usage: tsec <hostname|ip>"

  if [[ -z "$node" ]]; then
    echo "$usage"
    return 1
  fi

  tailscale set --exit-node="$node"
}

tsed() {
  tailscale set --exit-node=
}

# Aliases to use Mullvad VPN
tsvpn() {
  local cmd="${1-}"
  shift 2>/dev/null

  case "$cmd" in
    list|l)       tsvpnl "$@" ;;
    connect|c)    tsvpnc "$@" ;;
    disconnect|d) tsvpnd ;;
    help|*)
      echo "Usage: tsvpn <command> [args]"
      echo ""
      echo "Commands:"
      echo "  list       [country]   List Mullvad exit nodes (optionally filter by country)"
      echo "  connect    [country]   Connect to an exit node (uses suggested if no country given)"
      echo "  disconnect             Disconnect from current exit node"
      return 1
      ;;
  esac
}

tsvpnl() {
  local country="${1-}"

  if [[ -z "$country" ]]; then
    tsel | grep mullvad
  else
    tsel "$country" | grep mullvad
  fi
}

tsvpnc() {
  ts_no_exit_nodes || return 1
  local location="${1-}"
  local hostname label

  if [[ -z "$location" ]]; then
    hostname=$(tailscale exit-node suggest | head -1 | awk '{print $4}')
    hostname="${hostname%.}"
    label="suggested node"
  else
    hostname=$(tsel "$location" | grep -v '^$' | tail -n +2 | grep -v '^#' | head -1 | awk '{print $2}')
    label="$location"
  fi

  if [[ -z "$hostname" ]]; then
    echo "No exit node found for '${location:-suggested}'"
    return 1
  fi

  tsec "$hostname"
  echo "Connected to $label through $hostname"
}

tsvpnd() {
  local current
  current=$(tse)

  tsed

  if [[ -n "$current" ]]; then
    echo "Disconnected from $current"
  else
    echo "No exit node was active"
  fi
}
