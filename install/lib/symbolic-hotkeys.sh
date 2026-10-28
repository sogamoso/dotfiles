#!/usr/bin/env bash
# Sourced by install/macos/preferences.sh and `dotfiles doctor` — never run directly.

# System Settings → Keyboard → Keyboard Shortcuts, as "<id> on|off <character>,<key
# code>,<modifiers>", the entries of com.apple.symbolichotkeys. 65535 means no
# key. Modifiers add up: Shift 131072, Ctrl 262144, Option 524288, Cmd 1048576,
# and arrow keys carry Fn's 8388608. Only the sections docs/macos-manual-setup.md
# section 2 turns off are listed; the rest stay as macOS has them.
SYMBOLIC_HOTKEYS=(
  # Mission Control: AeroSpace owns the workspace chords
  "32 off 65535,126,8650752"   # Mission Control
  "33 off 65535,125,8650752"   # Application windows
  "36 off 65535,103,8388608"   # Show Desktop
  "79 off 65535,123,8650752"   # Move left a space
  "81 off 65535,124,8650752"   # Move right a space
  "118 off 65535,18,262144"    # Switch to Desktop 1
  "190 off 113,12,8388608"     # Quick Note
  # ...except these two, moved onto Option
  "163 on 44,43,524288"        # Show Notification Center → Option+,
  "175 on 44,43,786432"        # Turn Do Not Disturb on/off → Option+Ctrl+,
  # Windows: AeroSpace tiles
  "237 off 102,3,8650752"      # Fill
  "238 off 99,8,8650752"       # Center
  "239 off 114,15,8650752"     # Return to previous size
  "240 off 65535,123,8650752"  # Left half
  "241 off 65535,124,8650752"  # Right half
  "242 off 65535,126,8650752"  # Top half
  "243 off 65535,125,8650752"  # Bottom half
  "244 off 65535,65535,0"
  "245 off 65535,65535,0"
  "246 off 65535,65535,0"
  "247 off 65535,65535,0"
  "248 off 65535,123,8781824"
  "249 off 65535,124,8781824"
  "250 off 65535,126,8781824"
  "251 off 65535,125,8781824"
  "256 off 65535,65535,0"
  "257 off 65535,65535,0"
  "258 off 65535,65535,0"
  # Input Sources: Option+I switches language, and Ctrl+Space is the tmux and
  # herdr prefix
  "60 off 32,49,262144"        # Previous input source
  "61 off 32,49,786432"        # Next input source
  # Spotlight: Vicinae takes the slot
  "64 off 32,49,1048576"       # Show Spotlight search
  "65 off 32,49,1572864"       # Show Finder search window
  # Screenshots: CleanShot takes Cmd+Shift+3/4/5 through AeroSpace
  "28 off 51,20,1179648"
  "29 off 51,20,1441792"
  "30 off 52,21,1179648"
  "31 off 52,21,1441792"
  "184 off 53,23,1179648"      # Screenshot and recording options
)
