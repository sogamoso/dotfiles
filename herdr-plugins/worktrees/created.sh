#!/usr/bin/env bash
set -euo pipefail

# The worktree.created hook: gets a new checkout ready to work in, whichever
# way it was made (hrw, the worktree plugin, herdr's sidebar). Trusts its mise
# config, as hrw does, and copies in the main checkout's env files (.env,
# .env.local and the like, a few levels deep), which git leaves out of every new
# worktree. A file the checkout already has is left alone.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

worktree=$(jq -r '.data.worktree.path' <<<"$HERDR_PLUGIN_EVENT_JSON")
main=$(main_checkout "$worktree")

# A fork's pull request is code nobody here has pushed, and the worktree plugin
# opens it like any other. Its config isn't trusted and no secrets go near it:
# a checkout counts as ours only when its commit is already on origin or on
# another local branch. The fetch is best-effort, so a same-repo pull request's
# branch is current; offline, a checkout that can't be placed is left as is.
git -C "$main" fetch --quiet origin >/dev/null 2>&1 || true
branch=$(git -C "$worktree" symbolic-ref --quiet HEAD 2>/dev/null || true)
git -C "$worktree" for-each-ref --contains HEAD --format='%(refname)' refs/remotes/origin refs/heads |
  grep -qvxF "$branch" || exit 0

if command -v mise >/dev/null; then
  mise trust --quiet "$worktree" >/dev/null 2>&1 || true
fi

[[ $main == "$worktree" ]] && exit 0

(cd "$main" && find . -maxdepth 3 \( -name node_modules -o -name .git \) -prune -o -name '.env*' -type f -print) |
  while IFS= read -r file; do
    [[ -e $worktree/$file ]] && continue
    mkdir -p "$(dirname "$worktree/$file")"
    cp -p "$main/$file" "$worktree/$file"
  done
