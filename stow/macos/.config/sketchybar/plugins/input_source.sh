#!/usr/bin/env bash

BIN="$HOME/.cache/sketchybar/current_input_source"
SRC="$CONFIG_DIR/plugins/current_input_source.swift"
[ ! -f "$BIN" ] || [ "$SRC" -nt "$BIN" ] && {
  mkdir -p "$(dirname "$BIN")"
  swiftc "$SRC" -framework Carbon -o "$BIN" 2>/dev/null
}

SOURCE=$("$BIN" 2>/dev/null)

ACCENT=0xffa9b1d6   # pill accent for both fill and border
BAR_BG=0xff1a1b26   # bar background — used as label color on filled state

case "$SOURCE" in
  *US|*ABC)
    # EN — outlined (transparent fill, accent border)
    sketchybar --set "$NAME" \
      label="EN" \
      label.color="$ACCENT" \
      background.color=0x00000000 \
      background.border_color="$ACCENT" \
      background.border_width=1 \
      label.padding_right=5
    ;;
  *Spanish*)
    # ES — filled
    sketchybar --set "$NAME" \
      label="ES" \
      label.color="$BAR_BG" \
      background.color="$ACCENT" \
      background.border_width=0 \
      label.padding_right=4
    ;;
  *)
    sketchybar --set "$NAME" \
      label="${SOURCE##*.}" \
      label.color="$BAR_BG" \
      background.color="$ACCENT" \
      background.border_width=0
    ;;
esac
