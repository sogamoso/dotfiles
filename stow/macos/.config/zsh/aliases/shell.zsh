# General shell utilities

reload() {
  dotfiles reload && source "$HOME/.zshrc" && fc -R && clear
}
