# The fns are Omarchy's, unchanged but for two files. In ssh-reconnect zsh needs
# two edits: its `local argv` would be zsh's positional parameters, so it's
# renamed, and ${letters:i:1} would read as a history modifier, so the offset
# is $i. In tmux, tsl's first pane is ${panes[1]}, as zsh arrays start at 1, and
# tdl focuses $editor_pane, where Omarchy's selects tds's unset $opencode_pane.
# Left out: drives (lsblk and omarchy-drive-select) and rsyncing (setsid and
# inotifywait), both Linux only, and herdr, which aliases/herdr.zsh ports.
for f in "$HOME"/.config/zsh/omarchy/fns/*.zsh; do source "$f"; done
unset f
