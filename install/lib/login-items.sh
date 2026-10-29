#!/usr/bin/env bash
# Sourced by install/macos/login-items.sh and `dotfiles doctor` — never run directly.

# Apps that open at login. A missing one costs its feature silently: without
# MacWhisper, holding Right ⌘ does nothing.
LOGIN_ITEMS=(
  "/Applications/AeroSpace.app"
  "/Applications/CleanShot X.app"
  "/Applications/Dropbox.app"
  "/Applications/Freedom.app"
  "/Applications/Google Drive.app"
  "/Applications/Granola.app"
  "/Applications/MacWhisper.app"
  "/Applications/Slack.app"
  "/Applications/Vicinae.app"
  "$HOME/Applications/Chrome Apps.localized/Gmail.app"
  "$HOME/Applications/Chrome Apps.localized/Google Calendar.app"
)

# Current login items, one path per line. Fails without Automation access to
# System Events.
login_item_paths() {
  osascript -e 'tell application "System Events" to get the path of every login item' |
    tr ',' '\n' | sed 's/^ *//'
}
