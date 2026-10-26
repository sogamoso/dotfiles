#!/usr/bin/env bash
# Sourced by the plugin's scripts, never run directly. macOS runs them with its
# own bash 3.2, so nothing here needs bash 4.

herdr="${HERDR_BIN_PATH:-herdr}"

# The owner/repo of a checkout's GitHub origin, lowercased. Read from the config
# rather than `git remote get-url`, which applies insteadOf rewrites first.
# Usage: github_slug <dir>
github_slug() {
  local url
  url=$(git -C "$1" config --get remote.origin.url 2>/dev/null) || return 1
  [[ $url =~ github\.com[:/]([^/]+/[^/]+)$ ]] || return 1
  echo "${BASH_REMATCH[1]%.git}" | tr '[:upper:]' '[:lower:]'
}

# The top of a checkout of owner/repo: <dir>'s own when it is one, or else the
# first under ~/Work, laid out as ~/Work/<owner>/<repo> or ~/Work/<repo>
# Usage: checkout_for <owner/repo> [<dir>]
checkout_for() {
  local want dir
  want=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  for dir in "${2:-}" "$HOME"/Work/*/*/ "$HOME"/Work/*/; do
    [[ -n $dir && -d $dir ]] || continue
    if [[ $(github_slug "$dir") == "$want" ]]; then
      git -C "$dir" rev-parse --show-toplevel
      return
    fi
  done
  return 1
}
