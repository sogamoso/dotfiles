#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

log_heading "Setting macOS preferences..."

# Dark mode
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null ||
  log_warn "Could not set dark mode — grant Automation access to System Events and rerun"

# Scroll direction: non-natural
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Disable click desktop to reveal
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# 24-hour clock
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# Keyboard repeat speed
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Fn key: do nothing (0=nothing, 1=input source, 2=emoji, 3=dictation).
# Option+I switches input language instead, as Super+I does on Omarchy.
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

# System keyboard shortcuts that would fight AeroSpace, Vicinae and CleanShot for
# their chords, listed in lib/symbolic-hotkeys.sh. activateSettings applies them
# now; otherwise they wait for the next login.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/symbolic-hotkeys.sh"
for entry in "${SYMBOLIC_HOTKEYS[@]}"; do
  read -r id state params <<<"$entry"
  enabled=false
  [[ $state == "on" ]] && enabled=true
  integers=$(sed -E 's/([0-9]+),?/<integer>\1<\/integer>/g' <<<"$params")
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
    "<dict><key>enabled</key><$enabled/><key>value</key><dict><key>parameters</key><array>$integers</array><key>type</key><string>standard</string></dict></dict>"
done
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u ||
  log_warn "Could not apply the keyboard shortcuts now — they take effect at the next login"

# DNS: the servers in lib/dns.sh on every network service, whatever the network
# offers. docs/macos-manual-setup.md covers the tradeoffs and how to undo it.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/dns.sh"
while read -r service; do
  networksetup -setdnsservers "$service" "${DNS_SERVERS[@]}"
done < <(dns_services)

# Accessibility: disable UI transparency. WindowServer only reads this at login,
# so a fresh write leaves the revealed menu bar glassy on top of SketchyBar until
# the next one. Writing needs Full Disk Access — skipped if denied.
if [[ $(defaults read com.apple.universalaccess reduceTransparency 2>/dev/null) != "1" ]]; then
  if defaults write com.apple.universalaccess reduceTransparency -bool true 2>/dev/null; then
    log_warn "Reduced transparency set — log out and back in, or the menu bar stays transparent"
  else
    log_warn "Could not set reduceTransparency — grant Full Disk Access to Terminal and rerun"
  fi
fi

# CleanShot: clear the capture shortcuts it stores per machine. The same chords
# are AeroSpace bindings driving cleanshot:// URLs, so leaving these set puts two
# handlers on one key. CleanShot flushes its in-memory preferences on quit, which
# would restore the keys we just deleted — so it has to be closed first.
cleanshot_was_running=false
if pgrep -xq "CleanShot X"; then
  cleanshot_was_running=true
  osascript -e 'quit app "CleanShot X"' 2>/dev/null || pkill -x "CleanShot X" 2>/dev/null || true
  for _ in {1..20}; do
    pgrep -xq "CleanShot X" || break
    sleep 0.5
  done
fi

if pgrep -xq "CleanShot X"; then
  log_warn "CleanShot would not quit — its capture shortcuts were left alone"
else
  for key in LAVAtakeFullscreen LAVAtakeArea LAVAtakeAllInOne LAVAtakeOCR; do
    defaults delete pl.maketheweb.cleanshotx "$key" 2>/dev/null || true
  done
  # Those bindings only work if CleanShot accepts cleanshot:// URLs from other
  # apps, the Settings → Advanced → Allow URL scheme API toggle this key backs.
  # On CleanShot 5 the key alone isn't the whole story: once the URLs worked they
  # kept working with it false, and writing it true didn't revive them until the
  # toggle was flipped, so docs/macos-manual-setup.md keeps that step.
  defaults write pl.maketheweb.cleanshotx allowURLSchemesAPI -bool true
  if [[ $cleanshot_was_running == true ]]; then
    open -a "CleanShot X"
  fi
fi

# LanguageTool: clear its Correction and Paraphrasing shortcuts, which default to
# Option+Ctrl+C and Option+Ctrl+P, both AeroSpace bindings, and with them set
# those chords pop LanguageTool up. false is how its shortcut library stores
# "unassigned"; deleting the key brings the default back.
# It reads the shortcuts at launch and turns down a scripted quit, hence the
# pkill. Its own updater stays on: it sets SUAutomaticallyUpdate back at launch.
languagetool_was_running=false
if pgrep -xq "LanguageTool for Desktop"; then
  languagetool_was_running=true
  osascript -e 'quit app id "org.languagetool.desktop"' 2>/dev/null || pkill -x "LanguageTool for Desktop" 2>/dev/null || true
  for _ in {1..20}; do
    pgrep -xq "LanguageTool for Desktop" || break
    sleep 0.5
  done
fi

if pgrep -xq "LanguageTool for Desktop"; then
  log_warn "LanguageTool would not quit — clear its Correction and Paraphrasing shortcuts by hand"
else
  defaults write org.languagetool.desktop KeyboardShortcuts_Correction_Open -bool false
  defaults write org.languagetool.desktop KeyboardShortcuts_Paraphrasing_Open -bool false
  if [[ $languagetool_was_running == true ]]; then
    open -b org.languagetool.desktop
  fi
fi

# MacWhisper: dictation on Right ⌘, held to talk (Omarchy: hold Right Alt, which
# is Command here). It also writes its preferences back on quit, so close it first.
macwhisper_was_running=false
if pgrep -xq MacWhisper; then
  macwhisper_was_running=true
  osascript -e 'quit app "MacWhisper"' 2>/dev/null || pkill -x MacWhisper 2>/dev/null || true
  for _ in {1..20}; do
    pgrep -xq MacWhisper || break
    sleep 0.5
  done
fi

if pgrep -xq MacWhisper; then
  log_warn "MacWhisper would not quit — set its dictation key to Right ⌘ by hand"
else
  defaults write com.goodsnooze.MacWhisper dictationKeyboardButton -string rightCmd
  defaults write com.goodsnooze.MacWhisper dictationActivationMode -string pushToTalk
  if [[ $macwhisper_was_running == true ]]; then
    open -a MacWhisper
  fi
fi

# Menu bar: auto-hide
osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true' 2>/dev/null ||
  log_warn "Could not auto-hide the menu bar — grant Automation access to System Events and rerun"

# Menu bar controls (System Settings → Menu Bar → Menu Bar Controls): only Wi-Fi,
# Bluetooth and Text Input. Control Center stores each per host, 2 to show and 8
# to hide; Battery and KeyboardBrightness only exist on laptops. Siri and Text
# Input keep their own keys. "Allow in the Menu Bar" for third-party apps lives
# in an encoded list Control Center owns, so that part stays manual.
for item in WiFi Bluetooth; do
  defaults -currentHost write com.apple.controlcenter "$item" -int 2
done
for item in AirDrop Battery Display FocusModes KeyboardBrightness NowPlaying ScreenMirroring \
  Sound Spotlight TimeMachine Timer UserSwitcher Weather; do
  defaults -currentHost write com.apple.controlcenter "$item" -int 8
done
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.TextInputMenu visible -bool true
killall ControlCenter 2>/dev/null || true

# Dock: clear pinned apps, position, size, autohide
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 43

# Screensaver: 5 min idle, lock immediately
defaults -currentHost write com.apple.screensaver idleTime -int 300
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Display sleep: 30 min idle
sudo pmset -a displaysleep 30

# Read once into a variable: grep -q in a pipe can quit before system_profiler
# finishes writing, and pipefail would then read the Mac mini as a laptop
is_mac_mini=false
[[ $(system_profiler SPHardwareDataType 2>/dev/null) == *"Mac mini"* ]] && is_mac_mini=true

if $is_mac_mini; then
  # Mac mini: never sleep (desktop, always on AC), restart after power failure
  sudo pmset -a sleep 0 disksleep 0 autorestart 1
else
  # Mac laptop: wake at 8 AM weekdays (no forced 7 PM sleep — handled by idle-aware agent)
  sudo pmset repeat wakeorpoweron MTWRF 08:00:00
fi

killall Dock 2>/dev/null || true

# Work hours agents run on laptops only; the Mac mini stays awake via pmset.
# Stow puts the plists in ~/Library/LaunchAgents on every Mac and launchd loads
# that folder at each login, so the Mac mini has to disable them outright:
# launchctl disable persists, and launchd then skips them despite the plists.
# Reload a LaunchAgent from its stowed plist. Enabled first, since bootstrap
# refuses a disabled service. bootout can return before launchd has torn the
# job down, and a bootstrap that lands in that window fails (often as "5:
# Input/output error"), so it gets a few tries before failing the script.
reload_agent() {
  local label=$1 plist="$HOME/Library/LaunchAgents/$1.plist" try
  launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
  launchctl enable "gui/$(id -u)/$label"
  for try in 1 2 3 4 5; do
    launchctl bootstrap "gui/$(id -u)" "$plist" 2>/dev/null && return 0
    sleep 1
  done
  launchctl bootstrap "gui/$(id -u)" "$plist"
}

workhours_labels=(com.sogamoso.workhours.caffeinate-run com.sogamoso.workhours.caffeinate-watch com.sogamoso.workhours.sleep-if-idle)
if $is_mac_mini; then
  for label in "${workhours_labels[@]}"; do
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    launchctl disable "gui/$(id -u)/$label"
  done
else
  for label in "${workhours_labels[@]}"; do
    reload_agent "$label"
  done
fi

# Apply user key remappings via hidutil at login (Lofree mic-mute → F18), check
# daily that brew autoupdate hasn't left tailscaled or mosh-server blocked, run
# dotfiles update and doctor daily, notifying the result, and upgrade the mise
# coding agents every four hours
for label in com.sogamoso.keyboard.remap com.sogamoso.firewall-check com.sogamoso.dotfiles-daily com.sogamoso.agents-update; do
  reload_agent "$label"
done

log_success "macOS preferences set"
