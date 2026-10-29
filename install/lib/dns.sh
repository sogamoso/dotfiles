#!/usr/bin/env bash
# Sourced by install/macos/preferences.sh and `dotfiles doctor` — never run directly.

# DNS servers every network service on the Mac is pinned to, instead of the ones
# the network's DHCP hands out. Some networks hand out a resolver that drops
# queries (8.8.8.8 did from one ISP), and then nothing resolves, github.com
# included. Cloudflare and Quad9 answer from any network. Tailscale's MagicDNS
# names keep working: they go through /etc/resolver, not these.
DNS_SERVERS=(1.1.1.1 9.9.9.9)

# Enabled network services that reach a network: Wi-Fi, Ethernet adapters,
# iPhone USB. Thunderbolt Bridge only links two Macs, so it's left alone.
dns_services() {
  networksetup -listallnetworkservices | tail -n +2 | grep -v '^\*' | grep -vx 'Thunderbolt Bridge'
}
