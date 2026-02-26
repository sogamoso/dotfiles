# General shell utilities

reload() {
  (cd "$HOME/Code/dotfiles/stow" && stow --target "$HOME" --restow */) || return
  source "$HOME/.zshrc" || return
  if [[ -d "/Applications/Hammerspoon.app" ]]; then
    open "hammerspoon://reload" >/dev/null 2>&1 || return
  fi
  fc -R
  clear
}
