#!/usr/bin/env bash
set -euo pipefail

# Opens a pull request as a worktree workspace, grouped under its repo, and
# starts the review layout (hrl) in it, as hrw does for a new branch. A pull
# request from this repo checks out its own branch, tracking origin so a push
# lands on the pull request. One from a fork gets pr-<number>, marked untrusted
# (see lib.sh): it opens to a plain shell, since the agents run with their
# approvals off and would be reading the fork's instructions. When the branch
# already has a checkout, that one opens instead.
# Usage: pr.sh <repo> <number>

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

repo=$(main_checkout "$1") || { echo "$1 isn't in a git repository." >&2; exit 1; }
number="$2"

slug=$(github_slug "$repo") || { echo "$repo has no GitHub origin." >&2; exit 1; }
pr=$(gh pr view "$number" --repo "$slug" --json headRefName,isCrossRepository)

if [[ $(jq -r '.isCrossRepository' <<<"$pr") == "true" ]]; then
  branch="pr-$number"
  base="origin/pr/$number"
  refspec="+refs/pull/$number/head:refs/remotes/$base"
  upstream=""
else
  branch=$(jq -r '.headRefName // empty' <<<"$pr")
  [[ -n $branch ]] || { echo "gh gave no branch for $slug#$number." >&2; exit 1; }
  base="origin/$branch"
  refspec="+refs/heads/$branch:refs/remotes/$base"
  upstream="$base"
fi

existing=$(git -C "$repo" worktree list --porcelain |
  awk -v ref="branch refs/heads/$branch" '/^worktree / { path = substr($0, 10) } $0 == ref { print path }')
if [[ -n $existing ]]; then
  "$herdr" worktree open --cwd "$repo" --path "$existing" --focus >/dev/null
  exit
fi

git -C "$repo" fetch --quiet origin "$refspec"

# Before the checkout exists, so the worktree.created hook already sees it.
# Deleting the branch, as hrd does, drops it.
[[ -z $upstream ]] && git -C "$repo" config "branch.$branch.untrustedCheckout" true

# Checked below rather than by errexit, so a failure shows herdr's message
response=$("$herdr" worktree create --cwd "$repo" --branch "$branch" --base "$base" --label "$branch" --focus 2>&1) || true
pane=$(jq -r '.result.root_pane.pane_id // empty' <<<"$response" 2>/dev/null || true)
[[ -z $pane ]] && { jq -r '.error.message' <<<"$response" 2>/dev/null || echo "$response"; exit 1; } >&2

path=$(jq -r '.result.root_pane.cwd' <<<"$response")
if [[ -n $upstream ]]; then
  git -C "$path" branch --quiet --set-upstream-to "$upstream"
  "$herdr" pane run "$pane" hrl >/dev/null
else
  touch "$(git -C "$path" rev-parse --absolute-git-dir)/untrusted-checkout"
fi
