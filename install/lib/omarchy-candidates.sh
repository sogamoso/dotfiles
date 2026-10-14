#!/usr/bin/env bash
# Sourced by `dotfiles omarchy-downstream-candidates` — never run directly.
#
# Lists what changed in Omarchy since the last commit reviewed for downstreaming
# (recorded in .omarchy-reviewed), limited to what this repo's macOS port
# mirrors. It only gathers facts; deciding what's worth porting is the
# omarchy-downstream skill's job, which reads this output.
#
# Needs gh, signed in, and jq.

OMARCHY_REPO="basecamp/omarchy"
OMARCHY_STATE_FILE="${OMARCHY_STATE_FILE:-$DOTFILES/.omarchy-reviewed}"

# Omarchy files whose behavior the macOS side ports: bindings, shell aliases
# and functions, terminal tools, and the utilities status.sh, reminder.sh and
# mic-mute.sh are ported from. Add a path when porting something new.
OMARCHY_PARITY_PATHS=(
  default/hypr/bindings.lua
  default/hypr/bindings
  default/bash
  config/tmux
  config/ghostty
  config/btop
  config/starship.toml
  config/nvim
  bin/omarchy-reminder
  bin/omarchy-battery-status
  bin/omarchy-weather-status
  bin/omarchy-audio-input-mute
)

# Commit titles outside those paths that can still matter here
OMARCHY_KEYWORDS='herdr|tmux|alias|neovim|nvim|lazyvim|ghostty|starship|ssh|mosh|tailscale|clipboard|super ?\+|keybinding|hotkey|shortcut'

omarchy_reviewed_sha() { awk '!/^#/ && NF {print $1; exit}' "$OMARCHY_STATE_FILE"; }
omarchy_reviewed_date() { awk '!/^#/ && NF {print $2; exit}' "$OMARCHY_STATE_FILE"; }

omarchy_head() {
  local branch
  branch=$(gh api "repos/$OMARCHY_REPO" -q .default_branch)
  gh api "repos/$OMARCHY_REPO/commits/$branch" -q '.sha + " " + .commit.committer.date'
}

# "CHORD | description" for every binding in Omarchy's Hyprland config at a ref,
# whatever helper declares it (o.bind, o.bind_toggle, o.bind_hold, ...)
omarchy_bindings_at() {
  local ref=$1 file
  {
    echo default/hypr/bindings.lua
    gh api "repos/$OMARCHY_REPO/contents/default/hypr/bindings?ref=$ref" -q '.[].path' 2>/dev/null
  } | while IFS= read -r file; do
    gh api "repos/$OMARCHY_REPO/contents/$file?ref=$ref" -H "Accept: application/vnd.github.raw" 2>/dev/null |
      sed -nE 's/^[[:space:]]*o\.bind(_[a-z]+)?\("([^"]+)", "([^"]+)".*/\2 | \3/p'
  done | sort -u
}

# Whether aerospace.toml already ports a chord: its bindings say
# "# Omarchy: SUPER + X" in a few spellings, so compare without spaces.
omarchy_chord_ported() {
  local chord compact
  chord=$(tr -d ' ' <<<"$1" | tr '[:lower:]' '[:upper:]')
  compact=$(grep -o 'Omarchy: [^→—#]*' "$DOTFILES/stow/macos/.config/aerospace/aerospace.toml" |
    sed 's/^Omarchy: //' | tr -d ' ' | tr '[:lower:]' '[:upper:]')
  grep -qxF "$chord" <<<"$compact"
}

cmd_omarchy_list() {
  command -v gh >/dev/null 2>&1 || { echo "gh is required" >&2; return 1; }
  local base base_date head head_sha head_date
  base=$(omarchy_reviewed_sha)
  base_date=$(omarchy_reviewed_date)
  head=$(omarchy_head)
  head_sha=${head%% *}
  head_date=${head##* }

  echo "==> Omarchy ($OMARCHY_REPO): reviewed up to ${base:0:9} ($base_date), now at ${head_sha:0:9} ($head_date)"
  if [[ $base == "$head_sha" ]]; then
    echo "    Nothing new since the last review"
    return 0
  fi

  local total
  total=$(gh api "repos/$OMARCHY_REPO/compare/$base...$head_sha" -q .ahead_by)
  echo "    $total new commit(s)"

  echo
  echo "==> Key bindings added, removed or renamed"
  local before after
  before=$(omarchy_bindings_at "$base")
  after=$(omarchy_bindings_at "$head_sha")
  local line chord any=0
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    any=1
    chord=${line%% |*}
    if omarchy_chord_ported "$chord"; then
      echo "  + $line   [already in aerospace.toml]"
    else
      echo "  + $line"
    fi
  done < <(comm -13 <(echo "$before") <(echo "$after"))
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    any=1
    echo "  - $line"
  done < <(comm -23 <(echo "$before") <(echo "$after"))
  (( any )) || echo "  (none)"

  echo
  echo "==> Commits touching files the macOS port mirrors"
  local path seen=" " sha rest
  for path in "${OMARCHY_PARITY_PATHS[@]}"; do
    while IFS= read -r line; do
      sha=${line%% *}
      [[ $sha == "${base:0:9}" || $seen == *" $sha "* ]] && continue
      seen+="$sha "
      echo "  $line   [$path]"
    done < <(gh api --paginate "repos/$OMARCHY_REPO/commits?sha=$head_sha&path=$path&since=$base_date&per_page=100" \
      -q '.[] | .sha[0:9] + " " + .commit.committer.date[0:10] + " " + (.commit.message | split("\n")[0])' 2>/dev/null)
  done
  [[ $seen == " " ]] && echo "  (none)"

  echo
  echo "==> Other commits whose title mentions something this setup uses"
  any=0
  # The commits list rather than compare, which stops at 250 commits. --paginate
  # walks every page, so there is no cap
  while IFS= read -r line; do
    sha=${line%% *}
    rest=${line#* }
    [[ $sha == "${base:0:9}" || $seen == *" $sha "* ]] && continue
    grep -qiE "$OMARCHY_KEYWORDS" <<<"$rest" || continue
    grep -qiE 'translat|i18n|languages|\btests?\b' <<<"$rest" && continue
    any=1
    echo "  $line"
  done < <(gh api --paginate "repos/$OMARCHY_REPO/commits?sha=$head_sha&since=$base_date&per_page=100" \
    -q '.[] | .sha[0:9] + " " + .commit.committer.date[0:10] + " " + (.commit.message | split("\n")[0])' 2>/dev/null)
  (( any )) || echo "  (none)"

  echo
  echo "==> When the review is done: dotfiles omarchy-downstream-candidates --mark-reviewed"
}

# Record the current head as reviewed, so the next run starts from it
cmd_omarchy_mark_reviewed() {
  local head
  head=$(omarchy_head)
  cat >"$OMARCHY_STATE_FILE" <<EOF
# Last Omarchy commit reviewed for changes to bring into these dotfiles, and
# its date. \`dotfiles omarchy-downstream-candidates\` lists what came after it;
# --mark-reviewed moves it forward. Commit it so every Mac shares the point.
$head
EOF
  echo "==> Marked ${head%% *} as reviewed in ${OMARCHY_STATE_FILE#$DOTFILES/}"
}

# Run the review in an agent session, with the omarchy-downstream skill doing
# the judgment the list can't: Claude Code first, Codex if Claude isn't there.
cmd_omarchy_review() {
  cd "$DOTFILES"
  if command -v claude >/dev/null 2>&1; then
    exec claude "/sogamoso-skills:omarchy-downstream"
  elif command -v codex >/dev/null 2>&1; then
    exec codex "Use the omarchy-downstream skill to review the Omarchy changes I should bring into these dotfiles."
  fi
  echo "==> Neither claude nor codex is installed; here are the raw changes"
  cmd_omarchy_list
}
