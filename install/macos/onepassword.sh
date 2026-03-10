#!/usr/bin/env bash
set -euo pipefail

echo -e "\n==> Launching 1Password..."
if pgrep -f "1Password" >/dev/null; then
  echo "✓ 1Password already running; skipping launch"
else
  open -a "1Password"
  echo "✓ 1Password launched"
  echo -e "\n! 1Password setup:"
  echo "• Sign in to your account"
  echo "• Enable the SSH agent: Settings → Developer → Use the SSH agent"
fi
