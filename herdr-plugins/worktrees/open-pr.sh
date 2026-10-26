#!/usr/bin/env bash
set -euo pipefail

# The open-pr action. A Ctrl-click on a pull request link opens it with pr.sh,
# from a checkout of its repo: the clicked pane's, or else one under ~/Work.
# Nothing is on screen to show an error, so a failure becomes a notification.
# From a key binding there is no link, so it opens the picker instead.

dir="$(dirname "${BASH_SOURCE[0]}")"
source "$dir/lib.sh"

cwd=$(jq -r '.focused_pane_cwd // .workspace_cwd // empty' <<<"$HERDR_PLUGIN_CONTEXT_JSON")
url="${HERDR_PLUGIN_CLICKED_URL:-}"

if [[ -z $url ]]; then
  exec "$herdr" plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint pr-picker --env "PR_REPO=$cwd" >/dev/null
fi

[[ $url =~ ^https://github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]] || exit 0
slug="${BASH_REMATCH[1]}"
number="${BASH_REMATCH[2]}"

if ! repo=$(checkout_for "$slug" "$cwd"); then
  "$herdr" notification show "Can't open #$number" --body "No checkout of $slug here or under ~/Work" >/dev/null
  exit 1
fi

if ! output=$(bash "$dir/pr.sh" "$repo" "$number" 2>&1); then
  "$herdr" notification show "Can't open #$number" --body "$(tail -n 1 <<<"$output")" >/dev/null
  exit 1
fi
