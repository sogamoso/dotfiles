# hunk, with a note of the pane it runs in, so the dotfiles.hunk herdr plugin
# (herdr-plugins/hunk) can start it there again after a herdr server restart,
# which brings every pane back as an empty shell. The marker, named after the
# pane and holding the command line, lasts as long as hunk does: it goes when
# hunk exits, and outlives it only when the server took the shell down with it,
# which is what the plugin's startup hook looks for. Outside herdr, plain hunk.
hunk() {
  [[ -z $HERDR_PANE_ID ]] && { command hunk "$@"; return; }

  local dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/hunk-panes"
  local args="" rc

  (( $# > 0 )) && args=$(printf ' %q' "$@")
  mkdir -p "$dir"
  printf 'hunk%s\n' "$args" >"$dir/$HERDR_PANE_ID"
  command hunk "$@"
  rc=$?
  rm -f "${dir:?}/${HERDR_PANE_ID:?}"
  return $rc
}
