#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/ssh.sh"
bash "$DIR/stow.sh"
bash "$DIR/zshrc.sh"
bash "$DIR/hushlogin.sh"
bash "$DIR/coderabbit.sh"
bash "$DIR/claude-code.sh"
