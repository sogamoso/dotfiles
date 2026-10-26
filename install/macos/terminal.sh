#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Ghostty as the default terminal. macOS has no such setting: Terminal.app is
# simply what runs a double-clicked script or executable, so Ghostty takes
# those types over. Ghostty also declares the .sh family, but public.shell-script
# stays with Neovim (neovim.sh), so a .sh opens for editing. Terminal.app keeps
# the ssh:// and x-man-page:// links, which Ghostty doesn't declare. The
# AeroSpace bindings already open Ghostty directly.

BUNDLE_ID="com.mitchellh.ghostty"
UTIS=(
  com.apple.terminal.shell-script # .command, .tool
  public.unix-executable
)

log_heading "Setting Ghostty as the default terminal..."

if ! command -v duti >/dev/null 2>&1; then
  log_warn "duti not found — install via Brewfile first"
  exit 1
fi

# duti -s exits 0 even when the change doesn't take, so check each default and
# retry, as neovim.sh does
for uti in "${UTIS[@]}"; do
  for _ in 1 2 3 4 5; do
    duti -s "$BUNDLE_ID" "$uti" all
    [[ "$(duti -d "$uti" 2>/dev/null)" == "$BUNDLE_ID" ]] && continue 2
    sleep 1
  done
  log_warn "Couldn't make Ghostty the default for $uti"
done

log_success "Ghostty runs double-clicked scripts and executables"
