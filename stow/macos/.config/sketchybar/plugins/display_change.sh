#!/usr/bin/env bash

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/common.sh"

# Rebuilding the bar emits a display_change of its own, so reload only when the
# display set actually differs. Without this a self-inflicted event is
# indistinguishable from a real one and the bar reloads forever.
FINGERPRINT="${TMPDIR:-/tmp}/dotfiles-sketchybar-displays"
DISPLAYS=$(sketchybar --query displays)
[[ -f $FINGERPRINT && $DISPLAYS == "$(cat "$FINGERPRINT")" ]] && exit 0

# Backstop for displays that really do change while a rebuild is in flight:
# debounce from the end of the last rebuild, which sketchybarrc stamps, rather
# than from the moment a reload was asked for. A config run slower than the
# window would otherwise outrun it and re-trigger itself. The fingerprint is
# left alone when skipping, so the next event still sees the change rather than
# finding it already recorded as handled.
if [[ -f $RELOAD_STAMP ]]; then
  (( $(date +%s) - $(stat -f %m "$RELOAD_STAMP") < 5 )) && exit 0
fi

printf '%s\n' "$DISPLAYS" > "$FINGERPRINT"
touch "$RELOAD_STAMP"

sketchybar --reload
