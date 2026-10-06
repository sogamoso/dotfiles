#!/usr/bin/env bash

source "$CONFIG_DIR/lib/common.sh"

BIN="$CACHE_DIR/current_input_source"
build_swift "$CONFIG_DIR/plugins/current_input_source.swift" "$BIN" -framework Carbon

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
