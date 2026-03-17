# General shell utilities

reload() {
  {
    bash "$HOME/Code/dotfiles/install/dotfiles/all.sh" || return
    bash "$HOME/Code/dotfiles/install/macos/dotfiles.sh" || return
    source "$HOME/.zshrc" || return
    if command -v sketchybar &>/dev/null; then
      sketchybar --reload
    fi
    if command -v aerospace &>/dev/null; then
      "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
      aerospace reload-config
    fi
    fc -R
  } &>/dev/null
  clear
}
