#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/stow-orphans.sh"

# Omarchy keeps work in ~/Work, with ~/Work/tries for try's experiments, so
# ~/Code moves there. Safe to run on any machine, in any state, any number of
# times: bootstrap runs it first and dotfiles update right after pulling.
#
# ~/Code stays as a symlink to ~/Work, so every absolute path recorded anywhere
# (git worktrees, editors, herdr panes, running sessions) keeps resolving. What
# keys off the path itself is moved over: the stow links, mise's trusted
# configs and Claude Code's project histories.

code="$HOME/Code"
work="$HOME/Work"

finish() {
  mkdir -p "$work/tries"
}

# Already moved, or nothing to move
if [[ -L $code || ! -e $code ]]; then
  finish
  exit 0
fi

log_heading "Moving ~/Code to ~/Work..."

# The repo's place relative to ~/Code, when this checkout lives there
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
repo_rel=""
[[ $repo == "$code"/* ]] && repo_rel=${repo#"$code"/}

# ~/Work can already exist (Omarchy creates it). Merge only when nothing would
# collide; otherwise change nothing and say what's in the way.
if [[ -e $work ]]; then
  clashes=()
  for entry in "$code"/* "$code"/.[!.]*; do
    [[ -e $entry || -L $entry ]] || continue
    name=${entry##*/}
    [[ $name == ".DS_Store" ]] && continue
    [[ -e $work/$name || -L $work/$name ]] && clashes+=("$name")
  done
  if (( ${#clashes[@]} )); then
    log_warn "~/Code and ~/Work both have: ${clashes[*]}. Nothing was moved; rename or merge those by hand, then rerun."
    exit 0
  fi
  for entry in "$code"/* "$code"/.[!.]*; do
    [[ -e $entry || -L $entry ]] || continue
    [[ ${entry##*/} == ".DS_Store" ]] && { rm -f "$entry"; continue; }
    mv "$entry" "$work/"
  done
  rmdir "$code"
else
  mv "$code" "$work"
fi
ln -s Work "$code"
log_item "Moved ~/Code to ~/Work and left ~/Code linking to it"

# Stow writes relative links, which now reach the repo through the ~/Code
# symlink; stow would treat them as foreign. Drop them and restow from ~/Work.
if [[ -n $repo_rel ]]; then
  stow_dir="$work/$repo_rel/stow"
  while IFS= read -r dir; do
    for link in "$dir"/* "$dir"/.[!.]*; do
      [[ -L $link ]] || continue
      [[ $(readlink "$link") == *"Code/$repo_rel/stow/"* ]] && rm "$link"
    done
  done < <(_stow_target_dirs "$stow_dir")
  bash "$work/$repo_rel/install/dotfiles/stow.sh"
fi

# mise trusts configs by path; trust the same ones at their new path
trusted="${MISE_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/mise}/trusted-configs"
if command -v mise >/dev/null && [[ -d $trusted ]]; then
  for entry in "$trusted"/*; do
    [[ -L $entry ]] || continue
    target=$(readlink "$entry")
    [[ $target == "$code"/* ]] || continue
    mise trust --quiet "$work/${target#"$code"/}" >/dev/null 2>&1 || true
  done
fi

# Claude Code names a project's history after its path. Move each to the ~/Work
# name and leave the old name linking to it, so either path finds the history.
projects="$HOME/.claude/projects"
if [[ -d $projects ]]; then
  old_prefix=$(tr '/.' '--' <<<"$code")
  new_prefix=$(tr '/.' '--' <<<"$work")
  for dir in "$projects/$old_prefix"-*; do
    [[ -d $dir && ! -L $dir ]] || continue
    name=${dir##*/}
    new="$projects/$new_prefix${name#"$old_prefix"}"
    [[ -e $new ]] && continue
    mv "$dir" "$new"
    # ./ because these names start with a dash, which ln would read as an option
    ln -s "./${new##*/}" "$dir"
  done
fi

finish
log_success "Work lives in ~/Work"
