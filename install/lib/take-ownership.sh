#!/usr/bin/env bash
# Sourced by the stow scripts — never run directly.

# Installers that aren't ours drop real files where our stow packages want
# symlinks, and stow aborts the whole package rather than clobber one. Drop the
# real file so stow can take over. Anything we already own is a link, so it is
# left alone.
take_ownership() {
  local target
  for target; do
    [[ -f $target && ! -L $target ]] && rm "$target"
  done
  return 0
}
