#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Raycast extensions that sign in with OAuth (DayCal, Trek, …) come back from
# the browser through Raycast's redirect page, which opens a raycast://oauth
# (or com.raycast:/oauth) link. Vicinae runs them and handles that link, but
# its Mac app only registers vicinae://, and without Raycast installed nothing
# receives raycast:// links: the sign-in succeeds in the browser and never
# reaches the extension. Build a tiny AppleScript app that claims both schemes
# and hands each link to Vicinae's own CLI, the way its Linux desktop entry
# claims them for Vicinae itself.

APP="$HOME/Applications/Raycast Links.app"
BUNDLE_ID="com.sogamoso.raycast-links"
SCHEMES=(raycast com.raycast)
CLI="/Applications/Vicinae.app/Contents/MacOS/vicinae-cli"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

log_heading "Sending raycast:// links to Vicinae..."

if [[ ! -x $CLI ]]; then
  log_warn "Vicinae isn't installed; dotfiles brew installs it"
  exit 0
fi
if ! command -v duti >/dev/null 2>&1; then
  log_warn "duti not found — install via Brewfile first"
  exit 1
fi

# Rebuilt only when this script changed, as Neovim.app is
stamp=$(shasum "${BASH_SOURCE[0]}" | cut -d" " -f1)
plist="$APP/Contents/Info.plist"
if [[ $(/usr/libexec/PlistBuddy -c "Print :DotfilesBuildStamp" "$plist" 2>/dev/null) != "$stamp" ]]; then
  script="$(mktemp -t raycast-links).applescript"
  cat >"$script" <<APPLESCRIPT
on open location theURL
	do shell script quoted form of "$CLI" & " " & quoted form of theURL
end open location
APPLESCRIPT
  mkdir -p "$(dirname "$APP")"
  rm -rf "$APP"
  osacompile -o "$APP" "$script"
  rm -f "$script"

  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$plist" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName Raycast Links" "$plist"
  # No Dock icon for the moment it runs
  /usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$plist"
  /usr/libexec/PlistBuddy \
    -c "Add :CFBundleURLTypes array" \
    -c "Add :CFBundleURLTypes:0 dict" \
    -c "Add :CFBundleURLTypes:0:CFBundleURLName string Raycast links for Vicinae" \
    -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" \
    "$plist"
  for i in "${!SCHEMES[@]}"; do
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:$i string ${SCHEMES[$i]}" "$plist"
  done
  /usr/libexec/PlistBuddy -c "Add :DotfilesBuildStamp string $stamp" "$plist"

  # Editing Info.plist breaks osacompile's signature; re-sign ad hoc
  codesign --force --deep --sign - "$APP" >/dev/null 2>&1
  "$LSREGISTER" -f "$APP"
fi

# Copies of Raycast unpacked into temporary folders by an installer stay
# registered for its schemes after the folder is gone; drop them so none
# outranks this app
"$LSREGISTER" -dump 2>/dev/null |
  awk '/^path:/ { sub(/^path: +/, ""); sub(/ \(0x[0-9a-f]+\)$/, ""); print }' |
  grep '/Raycast\.app$' | sort -u |
  while IFS= read -r stale; do
    [[ -e $stale ]] || "$LSREGISTER" -u "$stale" 2>/dev/null || true
  done

for scheme in "${SCHEMES[@]}"; do
  duti -s "$BUNDLE_ID" "$scheme"
done
log_success "raycast:// sign-ins reach Vicinae through Raycast Links.app"
