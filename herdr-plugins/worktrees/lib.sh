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

# The main checkout of the repo <dir> is in, even from one of its worktrees
# Usage: main_checkout <dir>
main_checkout() {
  local common_dir
  common_dir=$(git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  dirname "$common_dir"
}
