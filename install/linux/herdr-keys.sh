#!/usr/bin/env bash
set -euo pipefail

# Runs the post-update hook once now, so the agent keys don't wait for the first
# Omarchy update.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/../../stow/linux/.config/omarchy/hooks/post-update.d/herdr-agent-keys"
