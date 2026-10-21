#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Set Reminder
# @vicinae.mode silent
# @vicinae.packageName Reminders
# @vicinae.icon ⏰
# @vicinae.argument1 { "type": "text", "placeholder": "Minutes" }
# @vicinae.argument2 { "type": "text", "placeholder": "Message", "optional": true }

"$HOME/.config/dotfiles/reminder.sh" set "$1" "${2:-}"
