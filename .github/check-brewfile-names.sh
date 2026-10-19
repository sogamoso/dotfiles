#!/usr/bin/env bash
# Looks up every Brewfile formula and cask in Homebrew, failing on any that
# no longer exists or has been disabled, and warning on deprecated ones.
# check.py covers the Brewfile's shape; this covers what upstream does to it,
# which changes without a commit here, hence the weekly run.
set -euo pipefail

cd "$(dirname "$0")/.."

source install/lib/brew-trust.sh
brew_trust_taps Brewfile
while IFS= read -r tap; do
  brew tap "$tap" >/dev/null
done < <(sed -nE 's/^tap "([^"]+)".*/\1/p' Brewfile)

failed=0
while read -r kind name; do
  if ! info=$(brew info --json=v2 "--$kind" "$name" 2>/dev/null); then
    echo "::error file=Brewfile::$kind \"$name\" not found in Homebrew"
    failed=1
    continue
  fi
  status=$(jq -r '(.formulae + .casks)[0] | if .disabled then "disabled" elif .deprecated then "deprecated" else "ok" end' <<<"$info")
  case $status in
    disabled)
      echo "::error file=Brewfile::$kind \"$name\" is disabled upstream"
      failed=1
      ;;
    deprecated)
      echo "::warning file=Brewfile::$kind \"$name\" is deprecated upstream"
      ;;
  esac
done < <(sed -nE 's/^(brew|cask) "([^"]+)".*/\1 \2/p' Brewfile | sed 's/^brew /formula /')

if (( failed )); then
  exit 1
fi
echo "Every Brewfile entry resolves"
