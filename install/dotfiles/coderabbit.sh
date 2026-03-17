#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Coderabbit. Writes directly to the .gitconfig so we need to strip it out
git -C "$REPO_DIR" config filter.strip-coderabbit.clean \
  "awk '/^\[coderabbit\]/{skip=1;next} /^\[/{skip=0} !skip{print}'"
