# General shell utilities

reload() {
  (cd "$HOME/Code/dotfiles/stow" && stow --target "$HOME" --restow */) || return
  source "$HOME/.zshrc" || return
  if [[ -d "/Applications/Hammerspoon.app" ]]; then
    open -g "hammerspoon://reload" >/dev/null 2>&1 || return
  fi
  if command -v sketchybar &>/dev/null; then
    sketchybar --reload
  fi
  fc -R
  clear
}
