#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# ui.sh's own installer drops a real SKILL.md here → let stow manage it instead
[[ -f "$HOME/.claude/skills/ui/SKILL.md" && ! -L "$HOME/.claude/skills/ui/SKILL.md" ]] && rm "$HOME/.claude/skills/ui/SKILL.md"

log_heading "Stowing dotfiles..."

cd "$REPO_DIR/stow"
packages=(claude editorconfig git mise nvim ruby ssh)

# Omarchy is bash-based and ships its own alias/function layer, so the zsh
# package is macOS only. Its bash counterpart lives in the linux package.
if [[ "$(uname -s)" == "Darwin" ]]; then
  packages+=(zsh)
fi

for config in "${packages[@]}"; do
  stow --target "$HOME" --restow --no-folding "$config"
done

log_success "Dotfiles stowed"
