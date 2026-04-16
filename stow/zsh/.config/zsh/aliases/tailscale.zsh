alias ts='tailscale'
alias tsed='tailscale set --exit-node='

tsel() {
  local filter="${1-}"

  if [[ -z "$filter" ]]; then
    tailscale exit-node list
  else
    tailscale exit-node list -filter="$filter"
  fi
}

tsec() {
  local node="${1-}"
  local usage="Usage: tsec <hostname|ip>"

  if [[ -z "$node" ]]; then
    echo "$usage"
    return 1
  fi

  tailscale set --exit-node="$node"
}

# Aliases to use Mullvad VPN
alias tsvpnd='tsed'

tsvpnl() {
  local filter="${1-}"

  if [[ -z "$filter" ]]; then
    tsel | grep mullvad
  else
    tsel "$filter" | grep mullvad
  fi
}

tsvpnc() {
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
