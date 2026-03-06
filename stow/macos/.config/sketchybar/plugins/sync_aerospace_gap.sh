#!/usr/bin/env bash
# Patch AeroSpace outer.top to match the sketchybar height.
# Called at sketchybar startup and by the shell reload() function before
# aerospace reload-config, ensuring correct ordering.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
MBHEIGHT_BIN="$CONFIG_DIR/plugins/menu_bar_height"
BAR_HEIGHT=$("$MBHEIGHT_BIN" 2>/dev/null || echo 30)

# On laptop-only (builtin display, macOS auto-hides menu bar without reserving
# space), keep a small aesthetic gap. When any external display is active, use
# the full bar height so windows don't cover sketchybar.
HAS_EXTERNAL=$(swift -e 'import AppKit; import CoreGraphics; let hasExternal = NSScreen.screens.contains { screen in guard let num = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }; return CGDisplayIsBuiltin(num.uint32Value) == 0 }; print(hasExternal ? 1 : 0)' 2>/dev/null || echo 0)

GAP=8

if [ "$HAS_EXTERNAL" -eq 1 ] 2>/dev/null; then
  AEROSPACE_TOP=$(( BAR_HEIGHT + GAP ))
else
  AEROSPACE_TOP=$(( 10 + GAP ))
fi

AEROSPACE_CFG="$HOME/.config/aerospace/aerospace.toml"
sed -i '' "s/^outer\.top[[:space:]]*=.*/outer.top        = $AEROSPACE_TOP/" "$AEROSPACE_CFG"
