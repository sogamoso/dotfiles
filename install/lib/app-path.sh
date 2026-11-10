#!/usr/bin/env bash
# Sourced by install/macos/app-path.sh and `dotfiles doctor` — never run directly.

# The PATH launchd gives every app it starts, login items and Dock launches
# included. Its default is only /usr/bin:/bin:/usr/sbin:/sbin, so anything an
# app runs by bare name from Homebrew isn't found: the Mise extension in Vicinae
# failed on `mise ls --json`. ~/.zprofile never reaches these apps.
APP_PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Where `launchctl config user path` keeps it. Readable without root.
APP_PATH_CONFIG="/private/var/db/com.apple.xpc.launchd/config/user.plist"

# The PATH set for apps, or nothing when launchd's default is in force
app_path_current() {
  plutil -extract PathEnvironmentVariable raw -o - "$APP_PATH_CONFIG" 2>/dev/null || true
}
