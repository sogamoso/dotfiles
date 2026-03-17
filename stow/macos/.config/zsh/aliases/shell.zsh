# General shell utilities

reload() {
  local ok=true
  bash "$HOME/Code/dotfiles/install/dotfiles/all.sh"   || ok=false
  bash "$HOME/Code/dotfiles/install/macos/dotfiles.sh" || ok=false
  source "$HOME/.zshrc"
  command -v sketchybar &>/dev/null && sketchybar --reload
  command -v aerospace &>/dev/null && {
    "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
    aerospace reload-config
  }
  fc -R
  clear
  $ok || echo "⚠ reload completed with errors"
}
