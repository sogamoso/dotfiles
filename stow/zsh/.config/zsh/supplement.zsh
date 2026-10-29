# Personal additions on top of the Omarchy port in ~/.config/zsh/omarchy.
# Sourced from ~/.zshrc right after it. Only includes things Omarchy doesn't
# provide.

# Locale (needed for SSH to remote hosts)
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Editors — omarchy/envs.zsh sets EDITOR to nvim; VISUAL is set here, and
# SUDO_EDITOR again so sudoedit stays on nvim when EDITOR is overridden
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

# terminal-browser sends usage telemetry unless told not to
export TERMINAL_BROWSER_NO_TELEMETRY=1

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
    [[ -r $file ]] && source "$file"
  done
fi

# zsh-you-should-use
YSU_IGNORED_ALIASES=("git")
if [[ -r "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh" ]]; then
  source "$HOME/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# ui.sh MCP token — Codex reads it from the environment at launch, where Claude
# Code keeps its own copy. Written by install/dotfiles/uidotsh.sh.
UIDOTSH_ENV="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/uidotsh.env"
[[ -r $UIDOTSH_ENV ]] && source "$UIDOTSH_ENV"
unset UIDOTSH_ENV

# herdr names a tab after its foreground program through this hook, which
# renames it as each command starts and ends. Found through herdr rather than a
# glob, which would also match an install a pin bump left behind.
if [[ -n $HERDR_PANE_ID ]] && command -v herdr >/dev/null; then
  HERDR_RENAME_HOOK="$(herdr plugin list --plugin herdr-automatic-rename --json 2>/dev/null |
    jq -r '.result.plugins[0].source.managed_path // empty' 2>/dev/null)/shell/hook.zsh"
  [[ -r $HERDR_RENAME_HOOK ]] && source "$HERDR_RENAME_HOOK"
  unset HERDR_RENAME_HOOK
fi

# Auto-attach to tmux on SSH
if [[ -z $TMUX && "$-" == *i* && -n "$SSH_TTY" ]]; then
  tmux attach || tmux new -s Work
fi

# Source OS-specific supplement
[[ -r "$HOME/.config/zsh/supplement.macos.zsh" ]] && source "$HOME/.config/zsh/supplement.macos.zsh"
