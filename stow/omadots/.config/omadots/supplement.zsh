# Personal additions for Omadots-managed shells.
# Sourced from ~/.zshrc by install/macos/omadots.sh.
# Only includes things Omadots doesn't provide.

# Editors Omadots doesn't set
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

# 1Password SSH Agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# History file and sizes
HISTFILE="$HOME/.history"
HISTSIZE=5000
SAVEHIST=20000

# 1Password CLI completion (requires compinit to have run first)
if command -v op >/dev/null 2>&1 && command -v compdef >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# Personal aliases
if [[ -d "$HOME/.zsh_aliases" ]]; then
  for file in "$HOME/.zsh_aliases"/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# zsh-you-should-use
if [[ -r "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# Auto-attach to tmux on SSH
if [[ -z "$TMUX" && "$-" == *i* && -n "$SSH_TTY" ]]; then
  tmux attach || tmux new -s Work
fi
