#!/usr/bin/env bash
# Sourced by the Vicinae cheatsheet scripts — never run directly.

# cheatsheet <title>
# Renders stdin under a title banner, so every cheatsheet looks the same. Each
# line is either `## Section`, which starts a section, or a key and its
# description separated by a tab; blank lines are skipped.

# Count characters, not bytes, so ─, → and – keep the columns aligned even when
# Vicinae runs the script without a locale
export LC_ALL=en_US.UTF-8

CHEATSHEET_WIDTH=56  # the rule under the title, and each section line
CHEATSHEET_KEY_WIDTH=28

cheatsheet_repeat() {
  local out="" n=$2
  while (( n-- > 0 )); do out+=$1; done
  printf '%s' "$out"
}

cheatsheet() {
  local B=$'\033[1m' D=$'\033[2m' C=$'\033[36m' Y=$'\033[33m' R=$'\033[0m'
  local line key desc pad

  printf '%s%s%s%s\n' "$B" "$Y" "$1" "$R"
  printf '%s%s%s\n' "$Y" "$(cheatsheet_repeat ━ "$CHEATSHEET_WIDTH")" "$R"

  while IFS= read -r line; do
    if [[ $line == "## "* ]]; then
      line=${line#\#\# }
      printf '\n%s%s── %s %s%s\n' "$B" "$C" "$line" "$(cheatsheet_repeat ─ $(( CHEATSHEET_WIDTH - 4 - ${#line} )))" "$R"
    elif [[ $line == *$'\t'* ]]; then
      key=${line%%$'\t'*}
      desc=${line#*$'\t'}
      pad=$(cheatsheet_repeat " " $(( CHEATSHEET_KEY_WIDTH - ${#key} )))
      printf '%s%s%s%s %s%s%s\n' "$B" "$key" "$R" "$pad" "$D" "$desc" "$R"
    fi
  done
}
