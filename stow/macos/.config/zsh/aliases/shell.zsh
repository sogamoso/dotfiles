# General shell utilities

reload() {
  local ok=true
  { bash "$HOME/Code/dotfiles/install/dotfiles/all.sh";   } &>/dev/null || ok=false
  { bash "$HOME/Code/dotfiles/install/macos/dotfiles.sh"; } &>/dev/null || ok=false
  { source "$HOME/.zshrc"; } &>/dev/null
  { command -v sketchybar &>/dev/null && sketchybar --reload; } &>/dev/null
  { command -v aerospace &>/dev/null && {
      "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
      aerospace reload-config
    }
  } &>/dev/null
  { fc -R; } &>/dev/null
  clear
  $ok || echo "⚠ reload completed with errors"
}
