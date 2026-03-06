# General shell utilities

reload() {
  (cd "$HOME/Code/dotfiles/stow" && stow --target "$HOME" --restow */) || return
  source "$HOME/.zshrc" || return
  if command -v sketchybar &>/dev/null; then
    sketchybar --reload
  fi
  if command -v aerospace &>/dev/null; then
    "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
    aerospace reload-config
  fi
  fc -R
  clear
}
