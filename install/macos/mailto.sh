#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Chrome's bundle declares no mailto scheme, and a Chrome PWA declares none at
# all, so neither can be the system handler. This applet can: LaunchServices
# delivers a clicked link as a GetURL Apple Event, which only an AppleScript
# `on open location` handler receives — a shell script in a bundle gets nothing.
APP="$HOME/Applications/Gmail Mailto.app"
BUNDLE_ID="so.sogamo.gmail-mailto"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

[[ -d "$APP" ]] && exit 0

log_heading "Building the Gmail mailto handler..."

source_script="$(mktemp -t gmail-mailto)"
cat > "$source_script" <<'APPLESCRIPT'
on open location this_URL
  set encoded to do shell script "printf %s " & quoted form of this_URL & " | /usr/bin/perl -pe 's/([^A-Za-z0-9._~-])/sprintf(\"%%%02X\",ord($1))/ge'"
  do shell script "/usr/bin/open -b com.google.Chrome " & quoted form of ("https://mail.google.com/mail/?extsrc=mailto&url=" & encoded)
end open location
APPLESCRIPT

osacompile -o "$APP" "$source_script"
rm -f "$source_script"

plist="$APP/Contents/Info.plist"
plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$plist"
plutil -replace CFBundleName -string "Gmail Mailto" "$plist"
plutil -insert CFBundleURLTypes \
  -json '[{"CFBundleURLName":"Mail","CFBundleURLSchemes":["mailto"]}]' "$plist"
# No Dock icon or menu bar — the applet hands off and exits.
plutil -replace LSUIElement -bool true "$plist"

"$LSREGISTER" -f "$APP"
duti -s "$BUNDLE_ID" mailto

log_item "$APP"
log_info "mailto: links now open a Gmail compose view"
