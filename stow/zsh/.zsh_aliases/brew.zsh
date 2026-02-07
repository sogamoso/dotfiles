# Only if Homebrew exists
command -v brew >/dev/null 2>&1 || return

alias bru='brew update'
alias brs='brew services'

bruu() {
  brew update || return
  brew upgrade "$@" || return
  brew cleanup
}
