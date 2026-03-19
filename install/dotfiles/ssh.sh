#!/usr/bin/env bash
set -euo pipefail

# Ensure .ssh exists before stowing SSH config
mkdir -p "$HOME/.ssh"
