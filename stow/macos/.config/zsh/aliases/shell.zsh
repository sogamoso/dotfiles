# General shell utilities

reload() {
  {
    bash "$HOME/Code/dotfiles/install/dotfiles.sh" || return
    bash "$HOME/Code/dotfiles/install/macos/dotfiles.sh" || return
    source "$HOME/.zshrc" || return
    if command -v sketchybar &>/dev/null; then
      sketchybar --reload
    fi
    if command -v aerospace &>/dev/null; then
      "$HOME/.config/sketchybar/plugins/sync_aerospace_gap.sh"
      aerospace reload-config
    fi
    local karabiner_cli="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
    if [[ -x "$karabiner_cli" ]]; then
      "$karabiner_cli" --select-profile 'Default profile'
    fi
    fc -R
  } &>/dev/null
  clear
}
