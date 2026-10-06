#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/zshrc.sh"
bash "$DIR/hushlogin.sh"
bash "$DIR/coderabbit.sh"
bash "$DIR/aerospace-gap.sh"
bash "$DIR/claude-code.sh"
bash "$DIR/codex.sh"
# uidotsh.sh first: it writes the token skills.sh checks ui.sh access with
bash "$DIR/uidotsh.sh"
bash "$DIR/skills.sh"
