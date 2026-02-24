# Print keyboard shortcut tables
hotkeys() {
  local section="${1:-all}"
  local pink='\033[38;5;212m' dim='\033[2m' bold='\033[1m' reset='\033[0m'

  _hotkeys_header() {
    printf "\n  ${pink}${bold}%s${reset}\n" "$1"
  }

  _hotkeys_row() {
    printf "  ${bold}%-26s${reset}  %s\n" "$1" "$2"
  }

  _hotkeys_note() {
    printf "  ${dim}%s${reset}\n" "$1"
  }

  _hotkeys_launch() {
    _hotkeys_header "APP LAUNCHING  (Raycast)"
    _hotkeys_row "⌘ Space"     "Raycast Launcher"
    _hotkeys_row "⌘ ⌃ ⏎"       "New Ghostty Window"
    _hotkeys_row "⌘ ⌃ A ⏎"     "New Alacritty Window"
    _hotkeys_row "⌘ ⌃ ⇧ ⏎"     "New Chrome Window"
  }

  _hotkeys_nav() {
    _hotkeys_header "WINDOW NAVIGATION  (Hammerspoon)"
    _hotkeys_row "⌘ ⌃ →"  "Focus window right"
    _hotkeys_row "⌘ ⌃ ←"  "Focus window left"
    _hotkeys_row "⌘ ⌃ ↑"  "Focus window above"
    _hotkeys_row "⌘ ⌃ ↓"  "Focus window below"
  }

  _hotkeys_pos() {
    _hotkeys_header "WINDOW POSITIONING  (Rectangle Pro)"
    _hotkeys_row "⌘ ⌥ ← / →"       "Left / Right Half"
    _hotkeys_row "⌘ ⌥ ↑ / ↓"       "Top / Bottom Left Quarter"
    _hotkeys_row "⌘ ⌥ ⇧ ↑ / ↓"     "Top / Bottom Right Quarter"
    _hotkeys_row "⌘ ⌥ ⌃ ← / →"     "First / Last Fourth"
    _hotkeys_row "⌘ ⌥ ⌃ ↑ / ↓"     "Top / Bottom Left Eighth"
    _hotkeys_row "⌘ ⌥ ⌃ ⇧ ↑ / ↓"   "Top / Bottom Right Eighth"
    _hotkeys_row "⌘ ⌥ ⏎"           "Center Half"
    _hotkeys_row "⌘ ⌥ ⌃ ⏎"         "Maximize"
  }

  _hotkeys_tmux() {
    _hotkeys_header "TMUX PANES"
    _hotkeys_note "Prefix: ⌃ Space  (or ⌃ B)"
    _hotkeys_row "⌃ ⌘ PageUp"     "Split horizontally"
    _hotkeys_row "⌃ ⌘ PageDown"   "Split vertically"
    _hotkeys_row "⌃ ⌘ End"        "Kill pane"
    _hotkeys_row "⌃ ⌘ ← / →"      "Focus left / right pane"
    _hotkeys_row "⌃ ⌘ ↑ / ↓"      "Focus up / down pane"
    _hotkeys_row "⌃ ⌘ ⇧ ← / →"    "Resize left / right"
    _hotkeys_row "⌃ ⌘ ⇧ ↑ / ↓"    "Resize up / down"

    _hotkeys_header "TMUX WINDOWS"
    _hotkeys_row "⌃ ⇧ Home"              "New window"
    _hotkeys_row "⌃ ⇧ End"               "Kill window"
    _hotkeys_row "⌃ ⇧ PageUp / PageDown" "Next / Previous window"
    _hotkeys_row "Prefix  x"             "Kill window"
    _hotkeys_row "Prefix  r"             "Rename window"

    _hotkeys_header "TMUX SESSIONS"
    _hotkeys_row "⌃ ⌘ ⇧ Home"            "New session"
    _hotkeys_row "⌃ ⌘ ⇧ End"             "Kill session"
    _hotkeys_row "⌃ ⌘ ⇧ PageUp / PageDn" "Prev / Next session"
    _hotkeys_row "Prefix  R"             "Rename session"
    _hotkeys_row "Prefix  X"             "Kill session"

    _hotkeys_header "TMUX COPY MODE  (Vi)"
    _hotkeys_row "v"           "Begin selection"
    _hotkeys_row "y"           "Copy selection"
    _hotkeys_row "Prefix  q"  "Reload config"
  }

  _hotkeys_legend() {
    printf "\n  ${dim}⌘ Command  ⌃ Control  ⌥ Option  ⇧ Shift  ⏎ Return${reset}\n"
  }

  case "$section" in
    launch|launching)  _hotkeys_launch; _hotkeys_legend ;;
    nav|navigation)    _hotkeys_nav; _hotkeys_legend ;;
    pos|positioning)   _hotkeys_pos; _hotkeys_legend ;;
    tmux|terminal)     _hotkeys_tmux; _hotkeys_legend ;;
    all)
      _hotkeys_launch
      _hotkeys_nav
      _hotkeys_pos
      _hotkeys_tmux
      _hotkeys_legend
      ;;
    help|-h|--help)
      printf "  ${pink}${bold}hotkeys${reset}\n"
      echo "  Print keyboard shortcut cheat sheets."
      echo
      printf "  ${dim}Usage: hotkeys [section]${reset}\n"
      echo
      echo "  launch, nav, pos, tmux    Show one section"
      echo "  (no argument)             Show all sections"
      return 0
      ;;
    *)
      printf "  ${pink}Unknown section: %s${reset}\n\n" "$section"
      echo "  Run ${bold}hotkeys help${reset} to see available sections."
      return 1
      ;;
  esac

  unset -f _hotkeys_header _hotkeys_row _hotkeys_note _hotkeys_legend _hotkeys_launch _hotkeys_nav _hotkeys_pos _hotkeys_tmux
}
