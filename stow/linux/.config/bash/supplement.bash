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

# terminal-browser sends usage telemetry unless told not to
export TERMINAL_BROWSER_NO_TELEMETRY=1

# Personal aliases
if [[ -d "$HOME/.config/bash/aliases" ]]; then
  for file in "$HOME/.config/bash/aliases"/*.bash; do
    [[ -r "$file" ]] && source "$file"
  done
fi

# ui.sh MCP token — Codex reads it from the environment at launch, where Claude
# Code keeps its own copy. Written by install/dotfiles/uidotsh.sh.
UIDOTSH_ENV="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/uidotsh.env"
[[ -r "$UIDOTSH_ENV" ]] && source "$UIDOTSH_ENV"
unset UIDOTSH_ENV

# herdr names a tab after its foreground program through this hook, which
# renames it as each command starts and ends. Found through herdr rather than a
# glob, which would also match an install a pin bump left behind.
if [[ -n $HERDR_PANE_ID ]] && command -v herdr >/dev/null; then
  HERDR_RENAME_HOOK="$(herdr plugin list --plugin herdr-automatic-rename --json 2>/dev/null |
    jq -r '.result.plugins[0].source.managed_path // empty' 2>/dev/null)/shell/hook.bash"
  [[ -r "$HERDR_RENAME_HOOK" ]] && source "$HERDR_RENAME_HOOK"
  unset HERDR_RENAME_HOOK
fi

# Auto-attach to tmux on SSH
if [[ -z "$TMUX" && "$-" == *i* && -n "$SSH_TTY" ]]; then
  tmux attach || tmux new -s Work
fi
