#!/usr/bin/env bash
# Pull request status for herdr, run every 30 seconds by the tab bar's status
# area (tab_bar_right in the herdr config). Every workspace whose branch has an
# open pull request gets a $pr token for its sidebar row, which the config
# colours, and the tab bar gets a count of them all:
#
#   passed   checks green, mergeable, nothing asked of it
#   running  checks still running, waiting on review, or a draft
#   blocked  a check failed, a conflict, changes requested, or behind its base
#
# One gh call per repo per run. No errexit, like a SketchyBar plugin: a repo gh
# can't read shouldn't blank the status of every other workspace.
set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
source="dotfiles.pr-status"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-pr-status.XXXXXX") || exit 0
trap 'rm -rf "$tmp"' EXIT

# Each workspace's directory: its focused pane's, or else its first pane's
panes=$("$herdr" pane list 2>/dev/null) || exit 0
jq -r '.result.panes | group_by(.workspace_id)[]
  | (map(select(.focused))[0] // .[0])
  | [.workspace_id, (.foreground_cwd // .cwd // "")] | @tsv' <<<"$panes" >"$tmp/workspaces"

passed=0
running=0
blocked=0

while IFS=$'\t' read -r workspace dir; do
  status=""
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  default=$(git -C "$dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
  url=$(git -C "$dir" config --get remote.origin.url 2>/dev/null)

  if [[ -n $branch && $branch != "${default#origin/}" && $branch != "main" && $branch != "master" &&
    $url =~ github\.com[:/]([^/]+/[^/]+)$ ]]; then
    slug="${BASH_REMATCH[1]%.git}"
    cache="$tmp/$(echo "$slug" | tr '/' '_').json"
    [[ -e $cache ]] || gh pr list --repo "$slug" --state open --limit 100 \
      --json number,headRefName,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup \
      >"$cache" 2>/dev/null || echo '[]' >"$cache"

    status=$(jq -r --arg branch "$branch" '
      def failed: any(.statusCheckRollup[]?;
        ((.conclusion // "") | IN("FAILURE", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"))
        or ((.state // "") | IN("FAILURE", "ERROR")));
      def pending: any(.statusCheckRollup[]?;
        (.__typename == "CheckRun" and .status != "COMPLETED")
        or ((.state // "") | IN("PENDING", "EXPECTED")));
      [.[] | select(.headRefName == $branch)][0] // empty
      | "#\(.number) " + (
          if failed then "blocked: checks failed"
          elif .mergeable == "CONFLICTING" then "blocked: conflict"
          elif .reviewDecision == "CHANGES_REQUESTED" then "blocked: changes requested"
          elif .mergeStateStatus == "BEHIND" then "blocked: behind base"
          elif pending then "running: checks"
          elif .isDraft then "running: draft"
          elif .reviewDecision == "REVIEW_REQUIRED" or .mergeStateStatus == "BLOCKED" then "running: review"
          elif .mergeable == "UNKNOWN" or .mergeStateStatus == "UNKNOWN" then "running: checking"
          else "passed" end)' "$cache" 2>/dev/null)
  fi

  case "$status" in
    *passed*) passed=$((passed + 1)) ;;
    *running*) running=$((running + 1)) ;;
    *blocked*) blocked=$((blocked + 1)) ;;
  esac

  # The TTL clears a token this script stops refreshing, should it stop running
  if [[ -n $status ]]; then
    "$herdr" workspace report-metadata "$workspace" --source "$source" --token "pr=$status" --ttl-ms 120000 >/dev/null 2>&1
  else
    "$herdr" workspace report-metadata "$workspace" --source "$source" --clear-token pr >/dev/null 2>&1
  fi
done <"$tmp/workspaces"

summary=""
(( passed )) && summary+=" 🟢 $passed"
(( running )) && summary+=" 🟠 $running"
(( blocked )) && summary+=" 🔴 $blocked"
[[ -n $summary ]] && echo "PRs$summary"
exit 0
