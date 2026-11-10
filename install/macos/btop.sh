#!/usr/bin/env bash
set -euo pipefail

# btop rewrites its whole config on exit, so like Omarchy we copy a seed in
# and leave the copy to btop rather than stowing it: a stowed link sent every
# save into the repo. An existing copy is left alone, as Omarchy's installer
# does; delete it to take the seed again.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_DIR/install/lib/log.sh"

config="$HOME/.config/btop/btop.conf"

# Macs stowed before this have a link into the repo, which may now dangle
[[ -L $config ]] && rm "$config"

if [[ ! -e $config ]]; then
  mkdir -p "$(dirname "$config")"
  cp "$REPO_DIR/config/btop/btop.conf" "$config"
  log_item "Copied the btop config into $config"
fi
