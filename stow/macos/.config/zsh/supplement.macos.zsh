# 1Password CLI completion — guard with -t 1 to skip non-interactive shells
# (prevents TCC "op would like to access data from other apps" dialog in background processes)
if [[ -t 1 ]] && command -v op >/dev/null 2>&1 && command -v compdef >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# Tokyo Night for gum's prompts
source "$HOME/.config/zsh/gum.zsh"
