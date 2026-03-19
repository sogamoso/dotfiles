#!/usr/bin/env bash

BIN="$HOME/.cache/sketchybar/current_input_source"
SRC="$CONFIG_DIR/plugins/current_input_source.swift"
[ ! -f "$BIN" ] || [ "$SRC" -nt "$BIN" ] && {
  mkdir -p "$(dirname "$BIN")"
  swiftc "$SRC" -framework Carbon -o "$BIN" 2>/dev/null
}

SOURCE=$("$BIN" 2>/dev/null)

case "$SOURCE" in
  *US|*ABC)    LABEL="EN"; BG=0xffa9b1d6; RPAD=5 ;;
  *Spanish*)   LABEL="ES"; BG=0xff7aa2f7; RPAD=4 ;;
  *)           LABEL="${SOURCE##*.}"; BG=0xffa9b1d6 ;;
esac

sketchybar --set "$NAME" label="$LABEL" background.color="$BG" label.padding_right="$RPAD"
