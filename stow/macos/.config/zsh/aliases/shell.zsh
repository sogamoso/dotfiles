# General shell utilities

reload() {
  {
    bash "$HOME/Code/dotfiles/install/dotfiles/all.sh"
    bash "$HOME/Code/dotfiles/install/macos/dotfiles.sh"
    source "$HOME/.zshrc"
    command -v sketchybar &>/dev/null && sketchybar --reload
    command -v aerospace &>/dev/null && {
      "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
      aerospace reload-config
    }
    fc -R
  } &>/dev/null
  clear
}
