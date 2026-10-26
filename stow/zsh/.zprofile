# Every login shell, interactive or not, gets its tools on PATH here, as
# Omarchy's env-bootstrap does from /etc/profile.d: `zsh -lc` callers such as
# mosh's herdr command never read ~/.zshrc. Interactive shells build on it there.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

typeset -U path
path+=("$HOME/.local/share/mise/shims" "$HOME/.local/bin")
