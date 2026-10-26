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

# Every area of Omarchy is either ported (watched for changes) or skipped (looked
# at and set aside), and an area in neither list is reported on every run until
# it's classified. Patterns are matched against areas: bin/omarchy-<family> for
# commands, <top>/<name> under config, default, etc and install, and the
# top-level name elsewhere. A glob covers a whole family; a plain path covers
# that file or directory. Today's lesson: the review only saw what changed in
# listed paths, so a whole approach Omarchy already had (agents as lazy mise
# tools, its mise settings) never surfaced. Classifying everything closes that.

# Ported: changes here can need bringing over. The shell (default/bash, ported
# file for file to stow/zsh/.config/zsh/omarchy), the tmux, starship and git
# configs the macOS side copies, terminal tools, herdr, the coding agents (which
# mise installs, how omarchy-agent launches each, the default agent), mise
# itself, hooks, launchers and webapps, capture, the bar widgets SketchyBar
# ports, toggles, updates, the CLI tools Omarchy installs, and the utilities
# status.sh, reminder.sh and mic-mute.sh are ported from.
OMARCHY_PARITY_PATHS=(
  default/hypr/bindings.lua
  default/hypr/bindings
  default/bash
  default/bashrc
  default/ghostty
  default/themed
  config/tmux
  config/ghostty
  config/btop
  config/starship.toml
  config/herdr
  config/git
  config/lazygit
  config/opencode
  config/omarchy
  etc/mise
  etc/mpv
  install/omarchy-base.packages
  install/user
  install/config
  shell
  'bin/omarchy-agent*'
  'bin/omarchy-audio*'
  'bin/omarchy-bar*'
  'bin/omarchy-battery*'
  'bin/omarchy-capture*'
  'bin/omarchy-default*'
  'bin/omarchy-git*'
  'bin/omarchy-hook*'
  'bin/omarchy-launch*'
  'bin/omarchy-mise*'
  'bin/omarchy-reminder*'
  'bin/omarchy-tailscale*'
  'bin/omarchy-toggle*'
  'bin/omarchy-update*'
  'bin/omarchy-weather*'
  'bin/omarchy-webapp*'
)

# Skipped: looked at and set aside. Linux desktop and system plumbing with no
# macOS counterpart, terminals and apps not used here, Omarchy's own packaging,
# development and docs, and themes (macOS keeps one theme by hand).
OMARCHY_SKIPPED_AREAS=(
  # Repo housekeeping, Omarchy's own development, docs and tests
  .editorconfig .github .gitignore .greptile .luarc.json agents AGENTS.md CLAUDE.md
  README.md LICENSE version docs plans scripts test manual icon.png icon.txt logo.svg logo.txt
  bin 'bin/omarchy-dev*' 'bin/omarchy-debug*' 'bin/omarchy-crash*' 'bin/omarchy-done*'
  'bin/omarchy-state*' 'bin/omarchy-lifecycle*' 'bin/omarchy-migrate*' 'bin/omarchy-version*'
  'bin/omarchy-channel*' 'bin/omarchy-upgrade*' 'bin/omarchy-reinstall*' 'bin/omarchy-plugin*'
  # Packaging and system management (pacman, AUR, boot, snapshots, kernel, drivers)
  'bin/omarchy-pkg*' 'bin/omarchy-install*' 'bin/omarchy-installed*' 'bin/omarchy-remove*'
  'bin/omarchy-refresh*' 'bin/omarchy-restart*' 'bin/omarchy-setup*' 'bin/omarchy-system*'
  'bin/omarchy-provision*' 'bin/omarchy-boot*' 'bin/omarchy-snapshot*' 'bin/omarchy-kernel*'
  'bin/omarchy-hw*' 'bin/omarchy-n1x*' 'bin/omarchy-hibernation*' 'bin/omarchy-sudo*'
  'bin/omarchy-security*' 'bin/omarchy-plymouth*' 'bin/omarchy-cmd*' 'bin/omarchy-apply*'
  migrations applications themes
  install/hardware install/helpers install/login install/post-install install/provisioning
  'install/omarchy-aarch64*' install/omarchy-other.packages install/omarchy-x86_64-only.packages
  # Linux desktop: Hyprland, Wayland, menus, notifications, input, displays, audio stack
  'bin/omarchy-hyprland*' 'bin/omarchy-menu*' 'bin/omarchy-notification*' 'bin/omarchy-osd*'
  'bin/omarchy-shell*' 'bin/omarchy-show*' 'bin/omarchy-screensaver*' 'bin/omarchy-sleep*'
  'bin/omarchy-power*' 'bin/omarchy-powerprofiles*' 'bin/omarchy-brightness*' 'bin/omarchy-display*'
  'bin/omarchy-monitor*' 'bin/omarchy-input*' 'bin/omarchy-bluetooth*' 'bin/omarchy-network*'
  'bin/omarchy-dns*' 'bin/omarchy-disk*' 'bin/omarchy-drive*' 'bin/omarchy-file*' 'bin/omarchy-dock*'
  'bin/omarchy-windows*' 'bin/omarchy-font*' 'bin/omarchy-locale*' 'bin/omarchy-language*'
  'bin/omarchy-i18n*' 'bin/omarchy-branding*' 'bin/omarchy-ascii*' 'bin/omarchy-tui*'
  'bin/omarchy-theme*' 'bin/omarchy-clipboard*' 'bin/omarchy-dictation*' 'bin/omarchy-voxtype*'
  'bin/omarchy-transcode*' 'bin/omarchy-upload*' 'bin/omarchy-games*' 'bin/omarchy-chromium*'
  'bin/omarchy-openclaw*'
  config/alacritty config/autostart config/chromium config/chromium-flags.conf config/fcitx5
  config/foot config/hypr config/hyprland-mimeapps.list config/hyprland-preview-share-picker
  config/imv config/kitty config/obsidian config/wireplumber config/xdg-desktop-portal
  default/agents default/alacritty default/alsa default/applications default/audio default/chromium
  default/environment.d default/firefox default/fontconfig default/fonts default/foot default/gpg
  default/gtk default/hypr default/i18n default/input-methods default/libalpm default/limine
  default/nautilus-python default/omarchy default/pacman default/plymouth default/regions
  default/sddm default/settings-runtime-profile default/snapper default/systemd default/tensaku
  default/udev default/uwsm default/v4l2-relayd default/voxtype default/wayland-sessions
  default/wireplumber default/xcompose default/xdg-terminal-exec
  etc/cups etc/docker etc/fastfetch etc/gnupg etc/limine-entry-tool.d etc/mkinitcpio.conf.d
  etc/modprobe.d etc/NetworkManager etc/nsswitch.conf etc/plymouth etc/profile.d etc/sddm.conf.d
  etc/security etc/sudoers.d etc/sysctl.d etc/systemd etc/sysusers.d etc/tmpfiles.d etc/udev
  etc/xdg etc/xkb
)

# Commit titles outside those paths that can still matter here
OMARCHY_KEYWORDS='herdr|tmux|alias|neovim|nvim|lazyvim|ghostty|starship|ssh|mosh|tailscale|clipboard|super ?\+|keybinding|hotkey|shortcut|agent|mise|worktree|hook|claude|codex|opencode|hunk|git'

omarchy_reviewed_sha() { awk '!/^#/ && NF {print $1; exit}' "$OMARCHY_STATE_FILE"; }
omarchy_reviewed_date() { awk '!/^#/ && NF {print $2; exit}' "$OMARCHY_STATE_FILE"; }

omarchy_head() {
  local branch
  branch=$(gh api "repos/$OMARCHY_REPO" -q .default_branch)
  gh api "repos/$OMARCHY_REPO/commits/$branch" -q '.sha + " " + .commit.committer.date'
}

# Every file path in Omarchy's tree at a ref
omarchy_files_at() {
  gh api "repos/$OMARCHY_REPO/git/trees/$1?recursive=1" -q '.tree[] | select(.type == "blob") | .path'
}

# The area a path belongs to: bin/omarchy-<family>, <top>/<name> under config,
# default, etc and install, or the top-level name
omarchy_area() {
  awk -F/ '{
    if ($1 == "bin" && $2 ~ /^omarchy-/) { split($2, a, "-"); print "bin/omarchy-" a[2] }
    else if (NF >= 2 && ($1 == "config" || $1 == "default" || $1 == "etc" || $1 == "install")) print $1 "/" $2
    else print $1
  }'
}

# Whether an area or path matches any pattern in the named list
omarchy_matches() {
  local subject=$1 list=$2[@] pattern
  for pattern in "${!list}"; do
    # shellcheck disable=SC2053
    [[ $subject == $pattern ]] && return 0
  done
  return 1
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
  local head_files base_files
  head_files=$(omarchy_files_at "$head_sha")
  base_files=$(omarchy_files_at "$base")

  echo "==> Commits touching what the macOS port mirrors"
  local path seen=" " sha rest pattern
  local -a watch=()
  for pattern in "${OMARCHY_PARITY_PATHS[@]}"; do
    if [[ $pattern == *'*'* ]]; then
      while IFS= read -r path; do
        # shellcheck disable=SC2053
        [[ $path == $pattern ]] && watch+=("$path")
      done <<<"$head_files"
    else
      watch+=("$pattern")
    fi
  done
  while IFS= read -r line; do
    sha=${line%% *}
    [[ $sha == "${base:0:9}" || $seen == *" $sha "* ]] && continue
    seen+="$sha "
    echo "  $line"
  done < <(printf '%s\n' "${watch[@]}" | xargs -P 8 -I{} gh api --paginate \
      "repos/$OMARCHY_REPO/commits?sha=$head_sha&path={}&since=$base_date&per_page=100" \
      -q '.[] | .sha[0:9] + " " + .commit.committer.date[0:10] + " " + (.commit.message | split("\n")[0])' 2>/dev/null |
    sort -k2,2 -k1,1 | uniq)
  [[ $seen == " " ]] && echo "  (none)"

  echo
  echo "==> Files added or removed outside the skipped areas"
  echo "    Commands by name; other files grouped by folder"
  # awk instead of head and grep: both end early, which pipefail turns into a failure
  local changes
  # diff exits 1 whenever the lists differ, which is the expected case
  changes=$(diff <(echo "$base_files" | sort) <(echo "$head_files" | sort) | sed -n 's/^> /+ /p; s/^< /- /p' || true)
  any=0
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    any=1
    echo "  $line"
  done < <(while IFS= read -r line; do
      [[ -n $line ]] || continue
      path=${line:2}
      omarchy_matches "$(omarchy_area <<<"$path")" OMARCHY_SKIPPED_AREAS && continue
      echo "$line"
    done <<<"$changes" |
    awk '{
      sign = substr($0, 1, 1); path = substr($0, 3)
      if (path ~ /^bin\//) { print sign " " path; next }
      dir = path; sub(/\/[^\/]*$/, "", dir)
      key = sign " " dir
      count[key]++
      if (count[key] <= 3) names[key] = names[key] (count[key] > 1 ? ", " : "") substr(path, length(dir) + 2)
    }
    END {
      for (key in count) {
        more = count[key] > 3 ? ", +" (count[key] - 3) " more" : ""
        print key "/ (" count[key] "): " names[key] more
      }
    }' | sort -k2)
  (( any )) || echo "  (none)"

  echo
  echo "==> New migrations that mention something this setup uses"
  echo "    Migrations are where Omarchy changes how existing installs work"
  local migration text others=0
  any=0
  while IFS= read -r migration; do
    [[ -n $migration ]] || continue
    text=$(gh api "repos/$OMARCHY_REPO/contents/$migration?ref=$head_sha" -H "Accept: application/vnd.github.raw" 2>/dev/null || true)
    if ! grep -qiE "$OMARCHY_KEYWORDS" <<<"$text"; then
      others=$((others + 1))
      continue
    fi
    any=1
    echo "  $migration"
    awk '/^#[^!]/ && n < 3 { sub(/^# */, "      "); print; n++ }' <<<"$text"
  done < <(comm -13 <(echo "$base_files" | grep '^migrations/' | sort) <(echo "$head_files" | grep '^migrations/' | sort) || true)
  (( any )) || echo "  (none)"
  (( others )) && echo "  ($others more about areas this setup doesn't use)"

  echo
  local area
  echo "==> Omarchy areas not yet classified as ported or skipped"
  echo "    Decide each one, then add it to OMARCHY_PARITY_PATHS or OMARCHY_SKIPPED_AREAS"
  any=0
  while IFS= read -r area; do
    omarchy_matches "$area" OMARCHY_PARITY_PATHS && continue
    omarchy_matches "$area" OMARCHY_SKIPPED_AREAS && continue
    any=1
    echo "  $area"
  done < <(omarchy_area <<<"$head_files" | sort -u)
  (( any )) || echo "  (none)"

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
