# Non-interactive shells have their PATH from ~/.zprofile and need nothing more
[[ -o interactive ]] || return

source "$HOME/.config/zsh/omarchy/rc.zsh"
source "$HOME/.config/zsh/supplement.zsh"
