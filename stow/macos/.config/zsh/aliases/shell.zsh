# General shell utilities

reload() {
  (cd "$HOME/Code/dotfiles/stow" && stow --target "$HOME" --restow */) || return
  source "$HOME/.zshrc" || return
  clear
}
