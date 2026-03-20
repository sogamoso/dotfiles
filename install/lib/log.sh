#!/usr/bin/env bash
# Styled logging helpers — uses gum when available, plain echo otherwise.

if command -v gum &>/dev/null; then
  log_heading() { echo; gum style --foreground 4 --bold "==> $1"; }
  log_success() { gum log --level info "$1"; }
  log_warn()    { gum log --level warn "$1"; }
  log_item()    { gum style --foreground 7 "• $1"; }
  log_info()    { gum style "$1"; }
else
  log_heading() { echo -e "\n==> $1"; }
  log_success() { echo "✓ $1"; }
  log_warn()    { echo "⚠ $1"; }
  log_item()    { echo "• $1"; }
  log_info()    { echo "$1"; }
fi
