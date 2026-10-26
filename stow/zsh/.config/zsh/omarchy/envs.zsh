# Changes: EDITOR defaults to nvim, not omarchy-launch-editor. Left out: BROWSER
# (macOS's open handles URLs), env-bootstrap (~/.zprofile does its job here) and
# the locale fallback (supplement.zsh sets the locale).

# Editor used by CLI
export EDITOR="${EDITOR:-nvim}"
export SUDO_EDITOR="$EDITOR"

export BAT_THEME=ansi

# Color man pages with bat
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac
