# Changes: zsh in place of bash throughout, and fzf's key bindings from
# Homebrew's prefix. Left out: completions, which complete the Linux-only
# omarchy command.

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if [[ -o interactive ]] && [[ ${TERM:-} != "dumb" ]] && command -v starship &> /dev/null; then
  eval "$(starship init zsh --print-full-init)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v try &> /dev/null; then
  try() {
    unfunction try
    eval "$(SHELL=/bin/zsh command try init ~/Work/tries)"
    try "$@"
  }
fi

# Only the key bindings (Ctrl-R, Ctrl-T, Alt-C): fzf's completion.bash rewraps
# ~76 commands' completions on every shell start, adding ~25ms before the prompt.
if command -v fzf &> /dev/null; then
  if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  fi
fi
