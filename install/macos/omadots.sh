#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ ! -f "$HOME/.config/shell/all" ]]; then
  log_heading "Installing Omadots..."
  curl -fsSL https://raw.githubusercontent.com/omacom-io/omadots/refs/heads/master/install.sh | zsh
else
  log_heading "Omadots already installed..."
  log_success "Skipping installation"
fi

# Omadots writes `. ~/.zshrc` into ~/.zprofile, the bash_profile pattern, but a
# zsh login shell reads .zshrc on its own too, so every terminal loaded it twice
# and the second `try init` opened try's picker. Non-interactive login shells
# (`zsh -lc`, as mosh uses for herdr) skip .zshrc, so they still need it here.
if [[ -f "$HOME/.zprofile" && "$(<"$HOME/.zprofile")" == ". ~/.zshrc" ]]; then
  cat >"$HOME/.zprofile" <<'EOF'
# Interactive shells read ~/.zshrc on their own; load it here only for
# non-interactive login shells (zsh -lc), which would otherwise skip it
[[ -o interactive ]] || . ~/.zshrc
EOF
  log_success "~/.zprofile loads ~/.zshrc only for non-interactive shells"
fi
