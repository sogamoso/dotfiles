#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/../dotfiles/stow.sh"
bash "$DIR/bashrc.sh"
bash "$DIR/terminal.sh"
bash "$DIR/herdr-keys.sh"
