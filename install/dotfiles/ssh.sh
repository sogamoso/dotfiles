#!/usr/bin/env bash
set -euo pipefail

# Ensure .ssh exists before stowing SSH config
mkdir -p "$HOME/.ssh"

# Export the git signing public key from 1Password (requires app integration)
SIGNING_KEY="$HOME/.ssh/id_ed25519_git_signing.pub"
if [[ ! -f "$SIGNING_KEY" ]] && command -v op &>/dev/null; then
  echo "==> Exporting git signing key from 1Password..."
  op item get "Git Signing Key" --account my.1password.com --fields "public key" > "$SIGNING_KEY"
fi
