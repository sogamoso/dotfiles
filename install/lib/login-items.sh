#!/usr/bin/env bash
# Sourced by install/macos/login-items.sh and `dotfiles doctor` — never run directly.

# Apps that open at login. A missing one costs its feature silently: without
# Granola, holding Right ⌘ does nothing. Granola also opens itself through its
# own launch at login; it stays here too, deliberately, so losing either still
# leaves dictation working. Superwhisper is not here on purpose: it's opened by
# hand for the rare offline dictation, and its own launch at login is off.
LOGIN_ITEMS=(
  "/Applications/AeroSpace.app"
  "/Applications/CleanShot X.app"
  "/Applications/Dropbox.app"
  "/Applications/Freedom.app"
  "/Applications/Google Drive.app"
  "/Applications/Granola.app"
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
