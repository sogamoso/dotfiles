#!/usr/bin/env bash
set -euo pipefail

# The pull request picker in a popup, on prefix+u: the open pull requests of
# the focused pane's repo, filtered as you type, and the chosen one opened with
# pr.sh. Escape closes it. An error stays on screen until a key is pressed, as
# in the agent keys' popups.

dir="$(dirname "${BASH_SOURCE[0]}")"
source "$dir/lib.sh"

fail() {
  echo "$1"
  read -rsn1
  exit 1
}

repo=$(main_checkout "${PR_REPO:-$HOME}") ||
  fail "The focused pane isn't in a git repository."
slug=$(github_slug "$repo") || fail "$(basename "$repo") has no GitHub origin."

prs=$(gh pr list --repo "$slug" --limit 100 --json number,title,headRefName \
  --template '{{range .}}{{printf "#%v" .number}}  {{.title}}  ({{.headRefName}}){{"\n"}}{{end}}') ||
  fail "gh couldn't list $slug's pull requests."
[[ -n $prs ]] || fail "$slug has no open pull requests."

choice=$(gum filter --placeholder "Pull request in $slug" <<<"$prs") || exit 0
number="${choice%% *}"

bash "$dir/pr.sh" "$repo" "${number#\#}" || { read -rsn1; exit 1; }
