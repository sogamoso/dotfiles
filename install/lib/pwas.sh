#!/usr/bin/env bash
# Sourced by install/macos/pwas.sh and `dotfiles doctor` — never run directly.

CHROME_APPS="$HOME/Applications/Chrome Apps.localized"

# Chrome web apps, as "name|url". Chrome only installs one by hand, so a missing
# one stays missing until someone notices: Gmail and Google Calendar are the
# mail and calendar.
PWAS=(
  "Audible|https://www.audible.com/library"
  "Gmail|https://mail.google.com"
  "Google Calendar|https://calendar.google.com"
  "Grok|https://grok.com"
  "X|https://x.com"
  "YouTube|https://youtube.com"
)
