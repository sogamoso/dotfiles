#!/usr/bin/env bash

source "$CONFIG_DIR/lib/common.sh"

BIN="$CACHE_DIR/switch_input_source"
build_swift "$CONFIG_DIR/plugins/switch_input_source.swift" "$BIN" -framework Carbon && "$BIN"
