#!/usr/bin/env bash
# Show an indicator when the dotfiles repo is behind origin.
# Hidden when in sync, when not a git repo, or when the upstream is unreachable.
set -u

DOTFILES="${DOTFILES:-$HOME/Code/dotfiles}"

hide() { sketchybar --set "$NAME" drawing=off; exit 0; }

[ -d "$DOTFILES/.git" ] || hide

git -C "$DOTFILES" fetch --quiet origin 2>/dev/null || exit 0

upstream=$(git -C "$DOTFILES" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || hide
behind=$(git -C "$DOTFILES" rev-list --count "HEAD..$upstream" 2>/dev/null) || behind=0

if [ "$behind" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$behind"
else
  sketchybar --set "$NAME" drawing=off
fi
