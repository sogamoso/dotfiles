# Personal additions for Omarchy-managed shells.
# Assumes Omarchy has already been installed.
# Sourced from ~/.bashrc via install/linux/bashrc.sh.
# Only includes things Omarchy doesn't provide.
#
# Counterpart: stow/zsh/.config/zsh/supplement.zsh. Keep the two in sync —
# see AGENTS.md, "Shell configs come in pairs".

# Locale (needed for SSH to remote hosts)
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Editors — Omarchy sets EDITOR in its own envs; set the rest here
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

# Personal aliases
if [[ -d "$HOME/.config/bash/aliases" ]]; then
  for file in "$HOME/.config/bash/aliases"/*.bash; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# Auto-attach to tmux on SSH
if [[ -z "$TMUX" && "$-" == *i* && -n "$SSH_TTY" ]]; then
  tmux attach || tmux new -s Work
fi
