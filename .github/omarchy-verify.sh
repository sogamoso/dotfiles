#!/usr/bin/env bash
# Checks an agent's work in the Omarchy workflows before anything else runs on
# it. The agent read third-party input, so everything it left is treated as
# hostile until checked: its git state, the paths it touched, and whether a
# secret it could read ended up in what gets published.
#
# Usage:
#   omarchy-verify.sh save-git                   before the agent: keep .git/config
#   omarchy-verify.sh restore-git                after: put it back, drop hooks
#   omarchy-verify.sh classification             only the classification file changed
#   omarchy-verify.sh catch-up <base> [recorded] commits since <base> stay off the
#                                                paths the review must not touch; with
#                                                recorded, the last commit is the
#                                                workflow's review record and may
#                                                change .omarchy-reviewed only
#   omarchy-verify.sh secrets <base> [file...]   no secret value in the changes or files
#
# The secrets mode compares against the values in CLAUDE_CODE_OAUTH_TOKEN and
# OPENAI_API_KEY, passed to that step only.
set -euo pipefail

saved="${RUNNER_TEMP:?}/omarchy-git-config"

# Paths the catch-up review must leave alone: what runs the workflows, the skill
# that steers it, git's own settings, and the review record the workflow writes
denied_prefixes=(.github/ .agents/ .claude/)
denied_paths=(.gitignore .gitattributes .omarchy-reviewed)

fail() { echo "::error::$*"; exit 1; }

# Every path git status reports, both sides of a rename, one per line; ignored
# files (the agent's message files) are left out
status_paths() {
  local entry code
  while IFS= read -r -d '' entry; do
    code=${entry:0:2}
    printf '%s\t%s\n' "$code" "${entry:3}"
    if [[ $code == R* || $code == C* ]]; then
      IFS= read -r -d '' entry
      printf '%s\t%s\n' "$code" "$entry"
    fi
  done < <(git status --porcelain=v1 -z --untracked-files=all)
}

case "${1:-}" in
  save-git)
    cp .git/config "$saved"
    ;;

  restore-git)
    cp "$saved" .git/config
    rm -rf .git/hooks .git/info/attributes
    ;;

  classification)
    changes=$(status_paths)
    [[ -z $changes ]] && exit 0
    [[ $changes == $' M\tinstall/lib/omarchy-candidates.sh' ]] ||
      fail "The agent changed more than install/lib/omarchy-candidates.sh:"$'\n'"$changes"
    ;;

  catch-up)
    base=${2:?base commit}
    tip=HEAD
    [[ -z $(status_paths) ]] || fail "The review left uncommitted changes:"$'\n'"$(status_paths)"
    if [[ ${3:-} == "recorded" ]]; then
      [[ $(git diff --name-only --no-renames -z HEAD^ HEAD | tr '\0' '\n') == ".omarchy-reviewed" ]] ||
        fail "The last commit should change .omarchy-reviewed and nothing else"
      tip=HEAD^
    fi
    while IFS= read -r -d '' path; do
      for prefix in "${denied_prefixes[@]}"; do
        [[ $path == "$prefix"* ]] && fail "The review changed $path, under $prefix, which it must not touch"
      done
      for denied in "${denied_paths[@]}"; do
        [[ $path == "$denied" ]] && fail "The review changed $path, which it must not touch"
      done
    done < <(git diff --name-only --no-renames -z "$base..$tip")
    ;;

  secrets)
    base=${2:?base commit}
    shift 2
    values=()
    [[ -n ${CLAUDE_CODE_OAUTH_TOKEN:-} ]] && values+=("$CLAUDE_CODE_OAUTH_TOKEN")
    [[ -n ${OPENAI_API_KEY:-} ]] && values+=("$OPENAI_API_KEY")
    (( ${#values[@]} )) || exit 0
    # Never print a match: the log is public. Gathered into a file rather than
    # piped: under pipefail a missing listed file, or grep -q quitting early on
    # a large diff, would fail the pipeline and read as no match.
    haystack=$(mktemp)
    trap 'rm -f "$haystack"' EXIT
    { git diff "$base"; git log -p --format=%B "$base..HEAD"; } >"$haystack"
    for file in "$@"; do
      [[ -f $file ]] && cat -- "$file" >>"$haystack"
    done
    if grep -qF -f <(printf '%s\n' "${values[@]}") "$haystack"; then
      fail "A secret value appears in the agent's changes; nothing was published"
    fi
    ;;

  *)
    sed -n '8,17p' "$0" >&2
    exit 64
    ;;
esac

# The checks above end on a test that passed by being false; reaching here means
# none failed
exit 0
