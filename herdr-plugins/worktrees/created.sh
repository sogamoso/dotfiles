#!/usr/bin/env bash
set -euo pipefail

# The worktree.created hook: gets a new checkout ready to work in, whichever
# way it was made (hrw, open-pr, herdr's sidebar). Trusts its mise config, as
# hrw does, and copies in the main checkout's env files (.env, .env.local and
# the like, a few levels deep), which git leaves out of every new worktree. A
# file the checkout already has is left alone.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

worktree=$(jq -r '.data.worktree.path' <<<"$HERDR_PLUGIN_EVENT_JSON")

untrusted_checkout "$worktree" && exit 0

if command -v mise >/dev/null; then
  mise trust --quiet "$worktree" >/dev/null 2>&1 || true
fi

main=$(main_checkout "$worktree")
[[ $main == "$worktree" ]] && exit 0

(cd "$main" && find . -maxdepth 3 \( -name node_modules -o -name .git \) -prune -o -name '.env*' -type f -print) |
  while IFS= read -r file; do
    [[ -e $worktree/$file ]] && continue
    mkdir -p "$(dirname "$worktree/$file")"
    cp -p "$main/$file" "$worktree/$file"
  done
