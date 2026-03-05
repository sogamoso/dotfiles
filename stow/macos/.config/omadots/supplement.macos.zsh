# 1Password CLI completion
if command -v op >/dev/null 2>&1 && command -v compdef >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi
