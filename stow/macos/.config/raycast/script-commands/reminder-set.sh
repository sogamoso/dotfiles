#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Set Reminder
# @raycast.mode silent
# @raycast.packageName Reminders
# @raycast.icon ⏰
# @raycast.argument1 { "type": "text", "placeholder": "Minutes" }
# @raycast.argument2 { "type": "text", "placeholder": "Message", "optional": true }

"$HOME/.config/dotfiles/reminder.sh" set "$1" "${2:-}"
