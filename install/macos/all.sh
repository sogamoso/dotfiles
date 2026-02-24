#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/omadots.sh"
bash "$DIR/setup.sh"
bash "$DIR/alacritty.sh"
