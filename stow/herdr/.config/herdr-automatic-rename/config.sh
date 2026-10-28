# Sourced by qu8n/herdr-automatic-rename (pinned in install/lib/herdr-plugins.sh)
# before its defaults. A tab is named after its program alone, "zsh" at a
# prompt and "tail" or "npm" while one runs, without the directory and branch in
# front: the sidebar already shows both for the workspace.
TAB_CONTEXT=0

# The plugin's list of short-lived commands that keep the shell name, less
# tail: `tail -f` runs until stopped, and should name its tab like a server.
IGNORED_PROGRAMS=(ls eza ll la cd z zoxide cat bat less more echo pwd clear which man head wc cp mv rm mkdir touch fzf sudo doas)
