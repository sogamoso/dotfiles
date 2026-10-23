#!/usr/bin/env bash

source "$CONFIG_DIR/lib/common.sh"
source "$CONFIG_DIR/lib/colors.sh"

BIN="$CACHE_DIR/current_input_source"
build_swift "$CONFIG_DIR/plugins/current_input_source.swift" "$BIN" -framework Carbon

# Omarchy parity: shown only when more than one layout is configured
if (( $("$BIN" --count 2>/dev/null || echo 2) < 2 )); then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

SOURCE=$("$BIN" 2>/dev/null)

ACCENT=$TEXT   # pill accent for both fill and border

case "$SOURCE" in
  *US|*ABC)
    # EN — outlined (transparent fill, accent border)
    sketchybar --set "$NAME" \
      drawing=on \
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
      drawing=on \
      label="ES" \
      label.color="$BG" \
      background.color="$ACCENT" \
      background.border_width=0 \
      label.padding_right=4
    ;;
  *)
    sketchybar --set "$NAME" \
      drawing=on \
      label="${SOURCE##*.}" \
      label.color="$BG" \
      background.color="$ACCENT" \
      background.border_width=0
    ;;
esac
