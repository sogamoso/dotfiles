#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/pwas.sh"

names=()
urls=()
for pwa in "${PWAS[@]}"; do
  [[ -d "$CHROME_APPS/${pwa%%|*}.app" ]] && continue
  names+=("${pwa%%|*}")
  urls+=("${pwa#*|}")
done

if (( ${#urls[@]} )); then
  log_heading "Installing PWAs..."
  open -a "Google Chrome" "${urls[@]}" "chrome://apps/" ||
    log_warn "Could not launch Chrome — open these URLs manually"
  for i in "${!names[@]}"; do
    log_item "${names[$i]} (${urls[$i]})"
  done
  log_info "Install each via ⋮ → Cast, save, and share → Install page as app"
  log_info "Then in the chrome://apps/ tab, right-click each PWA and set:"
  log_item "☑ Open as window"
  for name in "${names[@]}"; do
    log_item "Opening supported links → Open in $name"
  done
fi
