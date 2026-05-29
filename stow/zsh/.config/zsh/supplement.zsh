# Personal additions for Omadots-managed shells.
# Assumes Omadots have already been installed.
# Sourced from ~/.zshrc via install/dotfiles/zshrc.sh.
# Only includes things Omadots doesn't provide.

# Locale (needed for SSH to remote hosts)
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Editors (override Omadots' EDITOR=nvim from ~/.config/shell/envs)
export EDITOR="zed --wait"
export VISUAL="zed --wait"
export SUDO_EDITOR="nvim"

# Homebrew: auto-update at most every 4 hours
export HOMEBREW_AUTO_UPDATE_SECS=14400

# Enable zsh completion
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi

# Personal aliases
if [[ -d "$HOME/.config/zsh/aliases" ]]; then
  for file in "$HOME/.config/zsh/aliases"/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# zsh-you-should-use
YSU_IGNORED_ALIASES=("git")
if [[ -r "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# Auto-attach to tmux on SSH
if [[ -z "$TMUX" && "$-" == *i* && -n "$SSH_TTY" ]]; then
  tmux attach || tmux new -s Work
fi

# Source OS-specific supplement
[[ -r "$HOME/.config/zsh/supplement.macos.zsh" ]] && source "$HOME/.config/zsh/supplement.macos.zsh"
