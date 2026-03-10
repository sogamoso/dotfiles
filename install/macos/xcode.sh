#!/usr/bin/env bash
set -euo pipefail

# macOS prerequisite: Xcode Command Line Tools (provides git, compilers, etc.)
if ! xcode-select -p >/dev/null 2>&1; then
  echo -e "\n==> Xcode Command Line Tools not found. Launching installer..."
  xcode-select --install || true
  echo "Please complete the install, then run bootstrap again."
  exit 1
fi
