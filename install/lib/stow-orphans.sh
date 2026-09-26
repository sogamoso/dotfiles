#!/usr/bin/env bash
# Finds symlinks in $HOME that stow created but can no longer account for.
#
# Stow writes *relative* links, so moving this checkout leaves every link in
# $HOME pointing at the old path. Stow can't clean up after itself here either:
# --restow only reclaims links that resolve back into its own stow dir, so a
# relocated checkout treats all of them as foreign and aborts with conflicts.
# The same applies to a file deleted from a package — its link outlives it.
#
# Only a true move or a deleted checkout heals, though. Copy the repo instead
# and the old path survives, so every link still resolves and stow conflicts
# just the same — a live link into the stale copy is indistinguishable from a
# live link into this one, so there is nothing safe to key off.
#
# Sourced by the three stow scripts so a moved or pruned checkout heals on the
# next run, and by `dotfiles status` to report the damage without touching it.

# Directories stow writes into, derived from the packages themselves so a new
# package bringing a new top-level dir is covered without editing this list.
# Deriving them also keeps the scan off ~/Library at large, which is slow.
_stow_target_dirs() {
  local stow_dir="$1" rel
  while IFS= read -r rel; do
    [[ -d "$HOME/$rel" ]] && echo "$HOME/$rel"
  done < <(cd "$stow_dir" && find . -mindepth 2 -type d | sed 's|^\./[^/]*/||' | sort -u)
  echo "$HOME"  # packages with top-level files (.gitconfig, .editorconfig, …)
}

# Prints one orphan per line. An orphan is a broken symlink whose target points
# into some stow dir — ours, wherever it used to live. Requiring it to be broken
# is what makes this safe: a live link is never touched, and a dangling one does
# nothing for anybody.
stow_orphans() {
  local stow_dir="$1" dir link target
  while IFS= read -r dir; do
    for link in "$dir"/* "$dir"/.*; do
      [[ -L $link ]] || continue
      [[ -e $link ]] && continue
      target=$(readlink "$link")
      [[ $target == */stow/* ]] && echo "$link"
    done
  done < <(_stow_target_dirs "$stow_dir")
}

# Removes them, printing how many. Callers do their own logging.
prune_stow_orphans() {
  local stow_dir="$1" link pruned=0
  while IFS= read -r link; do
    [[ -n $link ]] || continue
    rm "$link" && pruned=$((pruned + 1))
  done < <(stow_orphans "$stow_dir")
  echo "$pruned"
}
