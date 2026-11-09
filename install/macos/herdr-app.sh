#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# The Herdr desktop app, beside the terminal herdr as Omarchy keeps it
# (omarchy-install-ai-herdr). The Brewfile's cask installs the app but not
# herdr-core, which runs its terminals, so this installs the core with Herdr's
# own installer when there is none, as Omarchy's step does: downloaded whole
# before it runs, checked by it against the release's SHA-256 and Herdr's code
# signature, into ~/.local/bin, where it updates itself from then on. Stow puts
# the keymap and the Tokyo Night theme in ~/.config/herdr-app; this picks the
# theme, which Herdr only does through its running window (app.theme sets the
# shown layout's theme, and Herdr keeps that choice), and turns off its usage
# telemetry in settings.json, leaving the rest of that file to Herdr. With
# --launch (bootstrap) a closed Herdr is opened first; without it, as on
# `dotfiles reload`, a closed Herdr is left closed and the theme waits.

THEME=omarchy
# Live custom-theme reloading, the version Omarchy's helper requires
MIN_VERSION=0.1.11
CORE_INSTALLER="https://releases.herdr.dev/core/install.sh"
APP_HOME="${HERDR_APP_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr-app}"

launch=0
[[ ${1:-} == "--launch" ]] && launch=1

[[ -d /Applications/Herdr.app ]] || exit 0

log_heading "Setting up the Herdr app..."

core_installed=0
if ! command -v herdr-core >/dev/null 2>&1 && [[ ! -x $HOME/.local/bin/herdr-core ]]; then
  installer=$(mktemp "${TMPDIR:-/tmp}/dotfiles-herdr-core.XXXXXX")
  trap 'rm -f "$installer"' EXIT
  if curl -fsSL --retry 3 "$CORE_INSTALLER" -o "$installer" && sh "$installer"; then
    log_success "herdr-core installed into ~/.local/bin"
    core_installed=1
  else
    log_warn "Could not install herdr-core; Herdr's window offers to, or run: curl -fsSL $CORE_INSTALLER | sh"
  fi
fi

# Off by default here, as terminal-browser's is. Herdr writes the rest.
mkdir -p "$APP_HOME"
python3 - "$APP_HOME/settings.json" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}
if settings.get("telemetry") is not False:
    settings["telemetry"] = False
    with open(path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
PY

if ! command -v herdr-app >/dev/null 2>&1; then
  log_warn "herdr-app isn't on PATH; the cask links it from /opt/homebrew/bin"
  exit 0
fi

version=$(herdr-app --version 2>/dev/null | awk '{print $2}')
if [[ $(printf '%s\n' "$MIN_VERSION" "${version:-0}" | sort -V | head -1) != "$MIN_VERSION" ]]; then
  log_warn "Herdr ${version:-unknown} can't pick a custom theme from outside; $MIN_VERSION or newer can"
  exit 0
fi

# herdr-app waits on a window that can't answer, as one without a core does,
# so every call to it gets a deadline
ask() {
  local deadline=$1 pid i
  shift
  herdr-app "$@" >/dev/null 2>&1 &
  pid=$!
  for (( i = 0; i < deadline * 2; i++ )); do
    if ! kill -0 "$pid" 2>/dev/null; then
      wait "$pid"
      return
    fi
    sleep 0.5
  done
  kill "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null || true
  return 1
}

if ! ask 5 status; then
  if pgrep -xq Herdr; then
    # A window opened before its core existed shows the install screen and
    # never answers; it finds the core only when opened again. Nothing runs
    # in a Herdr without a core, so closing it costs nothing.
    if (( core_installed == 0 )); then
      log_warn "Herdr is open but doesn't answer; quit and reopen it, then rerun: install/macos/herdr-app.sh"
      exit 0
    fi
    pkill -x Herdr
    sleep 2
  elif (( launch == 0 )); then
    log_item "Herdr isn't open; its theme is picked on the next run while it is"
    exit 0
  fi
  open -a Herdr
  for (( attempt = 0; attempt < 12; attempt++ )); do
    ask 5 status && break
  done
fi

if ask 15 "do" app.theme --name "$THEME"; then
  log_success "Herdr shows the $THEME theme"
else
  log_warn "Herdr didn't answer; pick Omarchy in its theme picker, or rerun: install/macos/herdr-app.sh"
fi
