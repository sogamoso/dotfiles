#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Neovim is a terminal program, so Finder can't open files with it directly.
# Build a tiny AppleScript app that hands the files to nvim in a new Ghostty
# window, opened in the first file's folder, and make it the default for text
# and code. Rebuilt on every run: it's cheap, and keeps it in step with this file.

APP="$HOME/Applications/Neovim.app"
BUNDLE_ID="com.sogamoso.neovim"
UTIS=(
  public.plain-text
  net.daringfireball.markdown
  public.source-code
  public.shell-script
  public.json
  public.yaml
)

log_heading "Setting Neovim as the default editor for text and code files..."

if ! command -v duti >/dev/null 2>&1; then
  log_warn "duti not found — install via Brewfile first"
  exit 1
fi

# Rebuilding re-signs the app, which macOS takes as a new app claiming these
# types and asks again which editor to keep, so only rebuild when this script
# changed since the last build.
stamp=$(shasum "${BASH_SOURCE[0]}" | cut -d" " -f1)

build_app() {
  script="$(mktemp -t neovim-app).applescript"
  cat >"$script" <<'APPLESCRIPT'
on run
	do shell script "open -na Ghostty --args -e nvim"
end run

on open theItems
	set fileArgs to ""
	repeat with anItem in theItems
		set fileArgs to fileArgs & " " & quoted form of POSIX path of anItem
	end repeat
	set firstPath to POSIX path of (item 1 of theItems)
	set dir to do shell script "dirname " & quoted form of firstPath
	do shell script "open -na Ghostty --args --working-directory=" & quoted form of dir & " -e nvim" & fileArgs
end open
APPLESCRIPT

  mkdir -p "$(dirname "$APP")"
  rm -rf "$APP"
  osacompile -o "$APP" "$script"
  rm -f "$script"

  plist="$APP/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$plist" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName Neovim" "$plist"
  # Declare what it opens, or Finder won't offer it and duti can't make it default
  /usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$plist" 2>/dev/null || true
  /usr/libexec/PlistBuddy \
    -c "Add :CFBundleDocumentTypes array" \
    -c "Add :CFBundleDocumentTypes:0 dict" \
    -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string Text" \
    -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor" \
    -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Alternate" \
    -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes array" \
    "$plist"
  for i in "${!UTIS[@]}"; do
    /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:$i string ${UTIS[$i]}" "$plist"
  done

  /usr/libexec/PlistBuddy -c "Add :DotfilesBuildStamp string $stamp" "$plist"

  # Editing Info.plist breaks osacompile's signature; re-sign ad hoc
  codesign --force --deep --sign - "$APP" >/dev/null 2>&1
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
}

built=$(/usr/libexec/PlistBuddy -c "Print :DotfilesBuildStamp" "$APP/Contents/Info.plist" 2>/dev/null || true)
[[ $built == "$stamp" ]] || build_app

# lsregister returns before LaunchServices knows the app, and duti -s exits 0
# even when the change doesn't take, so check each default and retry
for uti in "${UTIS[@]}"; do
  [[ "$(duti -d "$uti" 2>/dev/null)" == "$BUNDLE_ID" ]] && continue
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    duti -s "$BUNDLE_ID" "$uti" all
    [[ "$(duti -d "$uti" 2>/dev/null)" == "$BUNDLE_ID" ]] && continue 2
    sleep 1
  done
  log_warn "Couldn't make Neovim the default for $uti"
done

log_success "Neovim set as default for plain text, Markdown, source code, shell, JSON, YAML"
