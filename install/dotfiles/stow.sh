#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/stow-orphans.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/take-ownership.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Run by each OS's all.sh right after the tools it needs are installed, so the
# install steps that follow find their config in place.

# Ensure .ssh exists before stowing SSH config
mkdir -p "$HOME/.ssh"

packages=(claude codex editorconfig git mise nvim ruby ssh)

# Claude Code writes its own settings, and Omadots/Omarchy copy a whole config
# tree into ~/.config, mise's included. Nothing is known to write
# ~/.codex/AGENTS.md — it's here because a real file at that path conflicts the
# whole codex package, not just the one link. Skills are not stowed: they go to
# two agents, so skills.sh links them and handles what ui.sh leaves behind.
take_ownership \
  "$HOME/.claude/keybindings.json" \
  "$HOME/.claude/settings.json" \
  "$HOME/.codex/AGENTS.md" \
  "$HOME/.config/mise/config.toml"

case "$(uname -s)" in
  Darwin)
    # Omarchy is bash-based and ships its own alias/function layer, so the zsh
    # package is macOS only. Its bash counterpart lives in the linux package.
    packages+=(zsh macos)
    take_ownership \
      "$HOME/.config/btop/btop.conf" \
      "$HOME/.config/ghostty/config" \
      "$HOME/.config/zed/settings.json" \
      "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-run.plist" \
      "$HOME/Library/LaunchAgents/com.sogamoso.workhours.caffeinate-watch.plist" \
      "$HOME/Library/LaunchAgents/com.sogamoso.workhours.sleep-if-idle.plist"
    ;;
  Linux)
    packages+=(linux)
    # Omarchy seeds this as a real file from /etc/skel.
    # omarchy-reinstall-configs restores the original if you ever want it back.
    take_ownership "$HOME/.config/hypr/bindings.lua"
    ;;
esac

log_heading "Stowing dotfiles..."

orphans=$(prune_stow_orphans "$REPO_DIR/stow")
(( orphans > 0 )) && log_item "Cleared $orphans link(s) left by a previous checkout location"

cd "$REPO_DIR/stow"

# A conflict in one package shouldn't cost us the remaining packages, nor the
# install steps that run after this script
failed=""
for config in "${packages[@]}"; do
  stow --target "$HOME" --restow --no-folding "$config" || failed+=" $config"
done

if [[ -n $failed ]]; then
  log_warn "Could not stow:$failed"
  log_item "Resolve the conflicts above, then re-run bootstrap"
else
  log_success "Dotfiles stowed"
fi
