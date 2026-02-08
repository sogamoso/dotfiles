# Locale
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Default editors
export EDITOR="zed"
export VISUAL="zed"
export SUDO_EDITOR="nvim"

# 1Password SHH Agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Shell History
HISTFILE="$HOME/.history"
HISTSIZE=5000
SAVEHIST=20000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

autoload -Uz compinit
compinit -d "$HOME/.zcompdump"

# fzf keybindings + completion
source <(fzf --zsh)

# Mise
eval "$(mise activate zsh)"

# Starship prompt
eval "$(starship init zsh)"

# 1Password CLI
eval "$(op completion zsh)"; compdef _op op

# zoxide
eval "$(zoxide init zsh)"

if [[ -d "$HOME/.zsh_aliases" ]]; then
  for file in "$HOME/.zsh_aliases"/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# zsh-you-should-use
export YSU_MESSAGE_POSITION="after"
source "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh"
