#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Claude Code and Codex are lazy mise tools, reachable only through mise's shims,
# which a fresh machine's bootstrap shell doesn't have on PATH yet
if [[ -d $HOME/.local/share/mise/shims ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

bash "$DIR/zshrc.sh"
bash "$DIR/hushlogin.sh"
bash "$DIR/coderabbit.sh"
bash "$DIR/aerospace-gap.sh"
bash "$DIR/claude-code.sh"
bash "$DIR/codex.sh"
bash "$DIR/opencode.sh"
# uidotsh.sh first: it writes the token skills.sh checks ui.sh access with
bash "$DIR/uidotsh.sh"
bash "$DIR/skills.sh"
