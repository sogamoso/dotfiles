# Personal additions for Omadots-managed shells.
# Sourced from ~/.zshrc by install/omadots_supplement.sh.
# Only includes things Omadots doesn't provide.

# Locale (needed for SSH to remote hosts)
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Editors Omadots doesn't set
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

# Personal aliases
if [[ -d "$HOME/.config/zsh/aliases" ]]; then
  for file in "$HOME/.config/zsh/aliases"/*.zsh; do
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

# OS-specific supplement
[[ -r "$HOME/.config/omadots/supplement.macos.zsh" ]] && source "$HOME/.config/omadots/supplement.macos.zsh"
