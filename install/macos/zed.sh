#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Setting Zed as default editor for common text/code file types..."

if ! command -v duti >/dev/null 2>&1; then
  log_warn "duti not found — install via Brewfile first"
  exit 1
fi

ZED_ID="dev.zed.Zed"

for uti in \
  public.plain-text \
  net.daringfireball.markdown \
  public.source-code \
  public.shell-script \
  public.json \
  public.yaml \
; do
  duti -s "$ZED_ID" "$uti" all
done

log_success "Zed set as default for plain text, Markdown, source code, shell, JSON, YAML"
