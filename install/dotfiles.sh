#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "\n==> Stowing dotfiles..."

# Append personal supplement to .zshrc (Omadots is already installed by Omamac)
OVERLAY='source $HOME/.config/omadots/supplement.zsh'
grep -qxF "$OVERLAY" "$HOME/.zshrc" 2>/dev/null || echo "$OVERLAY" >> "$HOME/.zshrc"

# Append Ghostty local overlay include (Omamac owns base config)
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
GHOSTTY_OVERLAY='config-file = config.local'
if [[ -f "$GHOSTTY_CONFIG" ]]; then
  grep -qxF "$GHOSTTY_OVERLAY" "$GHOSTTY_CONFIG" 2>/dev/null || echo "$GHOSTTY_OVERLAY" >> "$GHOSTTY_CONFIG"
fi

# Append hotkeys module to Hammerspoon config (Omamac owns init.lua)
HS_INIT="$HOME/.config/hammerspoon/init.lua"
HS_OVERLAY='require("hotkeys")'
grep -qxF "$HS_OVERLAY" "$HS_INIT" 2>/dev/null || echo "$HS_OVERLAY" >> "$HS_INIT"

command -v stow >/dev/null 2>&1 || { echo "stow not found on PATH" >&2; exit 1; }
[[ -d "$REPO_DIR/stow" ]] || { echo "stow directory not found: $REPO_DIR/stow" >&2; exit 1; }

mkdir -p "$HOME/.ssh"

cd "$REPO_DIR/stow"

# Cross-platform configs
for config in */; do
  [[ "$config" == "macos/" ]] && continue
  stow --target "$HOME" --restow "$config"
done

# OS-specific configs
case "$(uname -s)" in
  Darwin) stow --target "$HOME" --restow macos ;;
esac
