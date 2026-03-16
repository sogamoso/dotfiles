#!/usr/bin/env bash

SOURCE=$(defaults read com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)

case "$SOURCE" in
  *US|*ABC)    LABEL="EN"; BG=0xffa9b1d6; RPAD=5 ;;
  *Spanish*)   LABEL="ES"; BG=0xff565f89; RPAD=4 ;;
  *)           LABEL="${SOURCE##*.}"; BG=0xffa9b1d6 ;;
esac

sketchybar --set "$NAME" label="$LABEL" background.color="$BG" label.padding_right="$RPAD"
