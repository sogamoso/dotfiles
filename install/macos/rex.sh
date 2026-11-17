#!/usr/bin/env bash
# Rex's theme and font, as Ghostty has them: Tokyo Night and JetBrains Mono.
# Rex's init.lua only binds keys, so these live in its preferences, which Rex
# writes from its Settings window. Nothing documents those keys, so this only
# writes when they look the way it expects, and otherwise leaves them to the
# Settings window: Settings > Theme > Import reads Ghostty's TokyoNight file.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOMAIN="com.superlogical.rex"
THEME_FILE="$REPO_DIR/config/rex/tokyo-night.json"
FONT="JetBrainsMono Nerd Font Mono"

log_heading "Setting Rex's theme and font..."

# Rex writes its preferences on first launch, onboarding's marker among them;
# before that there's nothing to check the format against. An emptied domain
# still reads as present, so this asks for the marker, not the domain.
if ! defaults read "$DOMAIN" Onboarding.firstRun >/dev/null 2>&1; then
  log_warn "Rex hasn't been opened yet; open it once, then rerun: install/macos/rex.sh"
  exit 0
fi

# Prints the custom themes with ours added or replaced, as hex for
# `defaults write -data`, or nothing when they're already in place. Exits 2 when
# Rex's stored themes aren't the list of objects with ids this expects.
status=0
themes_hex=$(defaults export "$DOMAIN" - | python3 -I -c '
import json, plistlib, sys
prefs = plistlib.loads(sys.stdin.buffer.read())
with open(sys.argv[1]) as f:
    ours = json.load(f)
raw = prefs.get("Workspace.customThemes")
if raw is None:
    themes = []
else:
    try:
        themes = json.loads(raw)
    except (TypeError, ValueError):
        sys.exit(2)
    if not isinstance(themes, list) or not all(isinstance(t, dict) and "id" in t for t in themes):
        sys.exit(2)
if ours in themes:
    sys.exit(0)
themes = [t for t in themes if t["id"] != ours["id"]] + [ours]
print(json.dumps(themes, separators=(",", ":")).encode().hex())
' "$THEME_FILE") || status=$?
if (( status == 2 )); then
  log_warn "Rex stores its themes in a form this script doesn't know; set the theme in Rex's Settings and update install/macos/rex.sh"
  exit 0
elif (( status != 0 )); then
  exit "$status"
fi

changed=0
if [[ -n $themes_hex ]]; then
  defaults write "$DOMAIN" Workspace.customThemes -data "$themes_hex"
  changed=1
fi

theme_id=$(python3 -I -c 'import json, sys; print(json.load(open(sys.argv[1]))["id"])' "$THEME_FILE")
set_string() {
  if [[ $(defaults read "$DOMAIN" "$1" 2>/dev/null) != "$2" ]]; then
    defaults write "$DOMAIN" "$1" -string "$2"
    changed=1
  fi
}
set_string Workspace.darkThemeID "$theme_id"
set_string Workspace.terminalFontName "$FONT"
if [[ $(defaults read "$DOMAIN" Workspace.terminalUseThemePalette 2>/dev/null) != 1 ]]; then
  defaults write "$DOMAIN" Workspace.terminalUseThemePalette -bool true
  changed=1
fi

if (( changed == 0 )); then
  log_success "Rex already has Tokyo Night and $FONT"
elif pgrep -xq Rex; then
  log_warn "Rex is open: quit and reopen it to pick up Tokyo Night and $FONT"
else
  log_success "Rex will open with Tokyo Night and $FONT"
fi
