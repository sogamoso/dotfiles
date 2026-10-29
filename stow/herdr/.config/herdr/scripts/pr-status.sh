#!/usr/bin/env bash
# Pull request status for herdr. Every agent pane whose branch has an open pull
# request gets $pr and $pr_url tokens for its row in the sidebar's agent panel,
# so the pull request shows only on the tab of the session that opened it, with
# a link. The config colours $pr by its status:
#
#   passed   checks green, mergeable, nothing asked of it
#   running  checks still running, waiting on review, or a draft
#   blocked  a check failed, a conflict, changes requested, or behind its base
#
# The tab bar's status area (tab_bar_right in the herdr config) runs this every
# 30 seconds, as its timer. It prints nothing, and herdr shows nothing for a
# command with no output, so the tab bar stays clear.
#
# One gh call per repo per run. No errexit, like a SketchyBar plugin: a repo gh
# can't read shouldn't blank the status of every other pane.
set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
source="dotfiles.pr-status"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-pr-status.XXXXXX") || exit 0
trap 'rm -rf "$tmp"' EXIT

# Only agent panes have rows in the agent panel
panes=$("$herdr" pane list 2>/dev/null) || exit 0
jq -r '.result.panes[] | select(.agent != null)
  | [.pane_id, (.foreground_cwd // .cwd // "")] | @tsv' <<<"$panes" >"$tmp/panes"

while IFS=$'\t' read -r pane dir; do
  status=""
  url=""
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  default=$(git -C "$dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
  remote=$(git -C "$dir" config --get remote.origin.url 2>/dev/null)

  if [[ -n $branch && $branch != "${default#origin/}" && $branch != "main" && $branch != "master" &&
    $remote =~ github\.com[:/]([^/]+/[^/]+)$ ]]; then
    slug="${BASH_REMATCH[1]%.git}"
    cache="$tmp/$(echo "$slug" | tr '/' '_').json"
    [[ -e $cache ]] || gh pr list --repo "$slug" --state open --limit 100 \
      --json number,url,headRefName,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup \
      >"$cache" 2>/dev/null || echo '[]' >"$cache"

    IFS=$'\t' read -r status url < <(jq -r --arg branch "$branch" '
      def failed: any(.statusCheckRollup[]?;
        ((.conclusion // "") | IN("FAILURE", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"))
        or ((.state // "") | IN("FAILURE", "ERROR")));
      def pending: any(.statusCheckRollup[]?;
        (.__typename == "CheckRun" and .status != "COMPLETED")
        or ((.state // "") | IN("PENDING", "EXPECTED")));
      [.[] | select(.headRefName == $branch)][0] // empty
      | ["#\(.number) " + (
          if failed then "blocked: checks failed"
          elif .mergeable == "CONFLICTING" then "blocked: conflict"
          elif .reviewDecision == "CHANGES_REQUESTED" then "blocked: changes requested"
          elif .mergeStateStatus == "BEHIND" then "blocked: behind base"
          elif pending then "running: checks"
          elif .isDraft then "running: draft"
          elif .reviewDecision == "REVIEW_REQUIRED" or .mergeStateStatus == "BLOCKED" then "running: review"
          elif .mergeable == "UNKNOWN" or .mergeStateStatus == "UNKNOWN" then "running: checking"
          else "passed" end), .url] | @tsv' "$cache" 2>/dev/null)
  fi

  # The TTL clears tokens this script stops refreshing, should it stop running
  if [[ -n $status ]]; then
    "$herdr" pane report-metadata "$pane" --source "$source" \
      --token "pr=$status" --token "pr_url=$url" --ttl-ms 120000 >/dev/null 2>&1
  else
    "$herdr" pane report-metadata "$pane" --source "$source" \
      --clear-token pr --clear-token pr_url >/dev/null 2>&1
  fi
done <"$tmp/panes"

exit 0
