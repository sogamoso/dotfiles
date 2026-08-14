# Homebrew — prepend to PATH so brew-installed tools take precedence over /usr/bin
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew zsh completions
if command -v brew >/dev/null 2>&1; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
typeset -U fpath

# Omadots defines open() as a wrapper around xdg-open, which does not exist on
# macOS. Because the wrapper redirects to /dev/null, it fails silently and
# shadows /usr/bin/open. Drop it so the native command wins.
unset -f open 2>/dev/null

# 1Password CLI completion — guard with -t 1 to skip non-interactive shells
# (prevents TCC "op would like to access data from other apps" dialog in background processes)
if [[ -t 1 ]] && command -v op >/dev/null 2>&1 && command -v compdef >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi
