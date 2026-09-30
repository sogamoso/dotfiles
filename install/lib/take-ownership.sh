#!/usr/bin/env bash
# Sourced by the stow scripts after log.sh — never run directly.

# Installers that aren't ours drop real files where our stow packages want
# symlinks, and stow aborts the whole package rather than clobber one. Move the
# real file aside so stow can take over, keeping it in case it held edits that
# exist nowhere else. Anything we already own is a link, so it is left alone.
take_ownership() {
  local target stamp
  stamp=$(date +%s)
  for target; do
    [[ -f $target && ! -L $target ]] || continue
    mv "$target" "$target.bak.$stamp"
    log_item "Moved $target aside to $target.bak.$stamp"
  done
  return 0
}
