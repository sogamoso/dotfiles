#!/usr/bin/env bash
# Checks an agent's edit to install/lib/omarchy-candidates.sh before the
# classification workflow pushes it to main. The file is sourced by the dotfiles
# CLI on every Mac, so the edit may only change the entries of the two lists:
# everything outside OMARCHY_PARITY_PATHS and OMARCHY_SKIPPED_AREAS must match
# the original byte for byte, and every line inside them must be paths, globs
# or a comment, with nothing the shell would expand or run.
#
# Usage: omarchy-classification-guard.sh <original> <edited>
set -euo pipefail

original=${1:?original file}
edited=${2:?edited file}

# The file with each list's body replaced by a marker
outside() {
  awk '
    /^OMARCHY_(PARITY_PATHS|SKIPPED_AREAS)=\($/ { print; print "<list>"; inside = 1; next }
    inside && /^\)$/ { inside = 0 }
    !inside { print }
  ' "$1"
}

# The lines of both lists' bodies
inside() {
  awk '
    /^OMARCHY_(PARITY_PATHS|SKIPPED_AREAS)=\($/ { inside = 1; next }
    inside && /^\)$/ { inside = 0; next }
    inside { print }
  ' "$1"
}

if ! diff <(outside "$original") <(outside "$edited") >/dev/null; then
  echo "::error::The edit changes omarchy-candidates.sh outside the two lists"
  diff <(outside "$original") <(outside "$edited") || true
  exit 1
fi

# An entry is a bare path, or a single-quoted glob. A line holds entries, a
# comment, or entries then a comment after whitespace: the shell only starts a
# comment at a word's start, so foo#$(cmd) would run cmd.
entry="([A-Za-z0-9._/+@-]+|'[A-Za-z0-9._/+@*?-]+')"
line="^[[:space:]]*((${entry}([[:space:]]+${entry})*)([[:space:]]+#.*)?|#.*)?[[:space:]]*$"
# And, as a second check, nothing that could expand or run outside a comment.
# A comment at a line's start or after whitespace is inert, and the line rule
# above already forces that.
unsafe='[]$`()\\;&|<>{}[]'
bad=$(inside "$edited" | grep -Ev "$line" || true)
bad+=$(inside "$edited" | sed -E 's/(^|[[:space:]])#.*$//' | grep -E "$unsafe" || true)
if [[ -n $bad ]]; then
  echo "::error::Lines in the lists that aren't plain entries or comments:"
  echo "$bad"
  exit 1
fi
