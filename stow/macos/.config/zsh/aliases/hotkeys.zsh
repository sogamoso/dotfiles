# Print keyboard shortcut tables using gum
hotkeys() {
  local section="${1:-all}"

  _hotkeys_header() {
    gum style --bold --foreground 212 --padding "0 1" "  $1"
  }

  _hotkeys_table() {
    {
      IFS=, read -r key action
      gum style --bold --foreground 212 "$(printf ' %-26s  %s' "$key" "$action")"
      while IFS=, read -r key action; do
        printf " %-26s  %s\n" "$key" "$action"
      done
    } | gum style --border rounded --border-foreground 240 --padding "0 1"
  }

  _hotkeys_launch() {
    _hotkeys_header "APP LAUNCHING  (Raycast)"
    echo "Shortcut,Action
⌘ Space,Raycast Launcher
⌘ ⌃ ⏎,New Ghostty Window
⌘ ⌃ A ⏎,New Alacritty Window
⌘ ⌃ ⇧ ⏎,New Chrome Window" | _hotkeys_table
  }

  _hotkeys_nav() {
    _hotkeys_header "WINDOW NAVIGATION  (Hammerspoon)"
    echo "Shortcut,Action
⌘ ⌃ →,Focus window right
⌘ ⌃ ←,Focus window left
⌘ ⌃ ↑,Focus window above
⌘ ⌃ ↓,Focus window below" | _hotkeys_table
  }

  _hotkeys_pos() {
    _hotkeys_header "WINDOW POSITIONING  (Rectangle Pro)"
    echo "Shortcut,Action
⌘ ⌥ ← / →,Left / Right Half
⌘ ⌥ ↑ / ↓,Top / Bottom Left Quarter
⌘ ⌥ ⇧ ↑ / ↓,Top / Bottom Right Quarter
⌘ ⌥ ⌃ ← / →,First / Last Fourth
⌘ ⌥ ⌃ ↑ / ↓,Top / Bottom Left Eighth
⌘ ⌥ ⌃ ⇧ ↑ / ↓,Top / Bottom Right Eighth
⌘ ⌥ ⏎,Center Half
⌘ ⌥ ⌃ ⏎,Maximize" | _hotkeys_table
  }

  _hotkeys_tmux() {
    _hotkeys_header "TMUX PANES"
    gum style --faint --foreground 245 --padding "0 2" "Prefix: ⌃ Space  (or ⌃ B)"
    echo "Shortcut,Action
⌃ ⌘ PageUp,Split horizontally
⌃ ⌘ PageDown,Split vertically
⌃ ⌘ End,Kill pane
⌃ ⌘ ← / →,Focus left / right pane
⌃ ⌘ ↑ / ↓,Focus up / down pane
⌃ ⌘ ⇧ ← / →,Resize left / right
⌃ ⌘ ⇧ ↑ / ↓,Resize up / down" | _hotkeys_table
    echo
    _hotkeys_header "TMUX WINDOWS"
    echo "Shortcut,Action
⌃ ⇧ Home,New window
⌃ ⇧ End,Kill window
⌃ ⇧ PageUp / PageDown,Next / Previous window
Prefix  x,Kill window
Prefix  r,Rename window" | _hotkeys_table
    echo
    _hotkeys_header "TMUX SESSIONS"
    echo "Shortcut,Action
⌃ ⌘ ⇧ Home,New session
⌃ ⌘ ⇧ End,Kill session
⌃ ⌘ ⇧ PageUp / PageDn,Prev / Next session
Prefix  R,Rename session
Prefix  X,Kill session" | _hotkeys_table
    echo
    _hotkeys_header "TMUX COPY MODE  (Vi)"
    echo "Shortcut,Action
v,Begin selection
y,Copy selection
Prefix  q,Reload config" | _hotkeys_table
  }

  _hotkeys_legend() {
    echo
    gum style --faint --foreground 245 --padding "0 1" \
      "⌘ Command  ⌃ Control  ⌥ Option  ⇧ Shift  ⏎ Return"
  }

  case "$section" in
    launch|launching)  _hotkeys_launch; _hotkeys_legend ;;
    nav|navigation)    _hotkeys_nav; _hotkeys_legend ;;
    pos|positioning)   _hotkeys_pos; _hotkeys_legend ;;
    tmux|terminal)     _hotkeys_tmux; _hotkeys_legend ;;
    all)
      _hotkeys_launch; echo
      _hotkeys_nav; echo
      _hotkeys_pos; echo
      _hotkeys_tmux; _hotkeys_legend
      ;;
    help|-h|--help)
      gum style --bold "hotkeys" --foreground 212
      echo "Print keyboard shortcut cheat sheets."
      echo
      gum style --faint "Usage: hotkeys [section]"
      echo
      echo "  launch, nav, pos, tmux    Show one section"
      echo "  (no argument)             Show all sections"
      return 0
      ;;
    *)
      gum style --foreground 9 "Unknown section: $section"
      echo
      echo "Run $(gum style --bold 'hotkeys help') to see available sections."
      return 1
      ;;
  esac

  unset -f _hotkeys_header _hotkeys_table _hotkeys_legend _hotkeys_launch _hotkeys_nav _hotkeys_pos _hotkeys_tmux
}
