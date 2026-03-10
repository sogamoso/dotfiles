#!/usr/bin/env bash
# Patch AeroSpace outer.top to match the sketchybar height.
# Called at sketchybar startup and by the shell reload() function before
# aerospace reload-config, ensuring correct ordering.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
MBHEIGHT_BIN="$CONFIG_DIR/plugins/menu_bar_height"
BAR_HEIGHT=$("$MBHEIGHT_BIN" 2>/dev/null || echo 30)

GAP=8
AEROSPACE_TOP=$(( BAR_HEIGHT + GAP ))

AEROSPACE_CFG="$HOME/.config/aerospace/aerospace.toml"
OLD_TOP=$(grep "^outer\.top" "$AEROSPACE_CFG" | awk '{print $3}')
sed -i '' "s/^outer\.top[[:space:]]*=.*/outer.top        = $AEROSPACE_TOP/" "$AEROSPACE_CFG"
if [ "$OLD_TOP" != "$AEROSPACE_TOP" ] && command -v aerospace &>/dev/null; then
  aerospace reload-config
fi
