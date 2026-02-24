# 1Password SSH Agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# 1Password CLI completion
if command -v op >/dev/null 2>&1 && command -v compdef >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi
