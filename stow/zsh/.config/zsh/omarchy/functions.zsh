# The fns are Omarchy's, unchanged. Left out: drives (lsblk and
# omarchy-drive-select) and rsyncing (setsid and inotifywait), both Linux only;
# herdr, which aliases/herdr.zsh ports; and ssh-reconnect, whose `local argv`
# is zsh's positional parameters, so it needs a real port rather than a copy.
for f in "$HOME"/.config/zsh/omarchy/fns/*.zsh; do source "$f"; done
unset f
