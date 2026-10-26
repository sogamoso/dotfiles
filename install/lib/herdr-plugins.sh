#!/usr/bin/env bash
# Sourced by install/dotfiles/herdr-plugins.sh and `dotfiles doctor` — never run directly.

# Third-party herdr plugins, one per line: plugin id, GitHub source, pinned commit.
# The worktree plugin creates worktrees from a pull request, an issue or a
# branch, and is what prefix+u and the Ctrl-click on a pull request link open.
HERDR_THIRD_PARTY_PLUGINS=(
  "worktree mkdir700/herdr-plugin-worktree 3d7ec281bc7e6a36850d99b2f15c35a3ed3f1359"
)
