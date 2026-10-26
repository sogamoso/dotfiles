#!/usr/bin/env bash
set -euo pipefail

# Runs worktree.setup or worktree.teardown from the repo's paseo.json the way
# Paseo does: from the worktree, with Paseo's variables set, as one script that
# stops at the first failing command, whether the config gives a string or an
# array of commands. Paseo reads the file from the base branch; this reads the
# copy created.sh saved when the worktree was made, which is that same file for
# a branch just made from the base, and stays put while the checkout changes.
# Succeeds quietly when the repo has no such phase, and for a fork's pull
# request, whose paseo.json is the fork's to write. created.sh runs setup, hrd
# runs teardown before it removes the checkout.
# Usage: paseo.sh <setup|teardown> <worktree>

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

phase="$1"
worktree="$2"
config=$(paseo_config "$worktree") || exit 0

[[ -f $config ]] || exit 0
untrusted_checkout "$worktree" && exit 0
script=$(jq -r --arg phase "$phase" '.worktree[$phase] // empty | if type == "array" then join("\n") else . end' "$config")
[[ -n $script ]] || exit 0

PASEO_SOURCE_CHECKOUT_PATH=$(dirname "$(git -C "$worktree" rev-parse --path-format=absolute --git-common-dir)")
PASEO_WORKTREE_PATH="$worktree"
PASEO_BRANCH_NAME=$(git -C "$worktree" branch --show-current)
export PASEO_SOURCE_CHECKOUT_PATH PASEO_WORKTREE_PATH PASEO_BRANCH_NAME

cd "$worktree"
echo "==> paseo.json worktree.$phase"
bash -e -c "$script"
