#!/usr/bin/env bash
# Claude Code status line: claude-hud + worktree indicator
input=$(cat)
plugin_dir=$(ls -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null \
  | awk -F/ '{ print $(NF-1) "\t" $(0) }' \
  | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n \
  | tail -1 | cut -f2-)

hud=$(echo "$input" | /opt/homebrew/bin/node "${plugin_dir}dist/index.js")

cwd=$(echo "$input" | jq -r .cwd)
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  main=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  gitdir=$(git -C "$cwd" rev-parse --path-format=absolute --git-dir 2>/dev/null)
  if [ "$main" != "$gitdir" ]; then
    first=$(echo "$hud" | head -1)
    rest=$(echo "$hud" | tail -n +2)
    hud="${first} \033[36m[worktree]\033[0m"$'\n'"${rest}"
  fi
fi

printf "%s" "$hud"
