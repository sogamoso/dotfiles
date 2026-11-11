#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# T3 Code, installed as Omarchy installs it (omarchy-install-ai-t3-code), plus
# one departure: the standalone `t3` CLI and its background service on every
# host, so each machine's agents stay reachable from the phone and the other
# Macs with the app closed. Closing the app's last window stops its own server.
#
# The app: Omarchy's installer on Linux (AppImage, launcher, theme), the
# Brewfile's t3-code cask on macOS. Omarchy points T3 Code at its palette by
# publishing omarchy.json into T3's state dir and selecting it; on macOS that
# file is Omarchy's t3code.json.tpl rendered for Tokyo Night, stowed into
# ~/.t3/userdata/themes, and selected here.
#
# The CLI comes from T3's own installer, downloaded whole before it runs and
# checked by it against the release's SHA-256. It shares ~/.t3 with the app
# and replaces only a `t3` link that is T3's own, the app's launcher included,
# so Omarchy's link to that launcher gives way and nothing else does. The
# service runs a runtime of its own under ~/.t3/runtime, which T3's update
# button in the app keeps in step with the app.

T3CODE_HOME="${T3CODE_HOME:-$HOME/.t3}"
T3="$HOME/.local/bin/t3"
INSTALLER="https://t3.codes/install.sh"

log_heading "Setting up T3 Code..."

case "$(uname -s)" in
  Darwin)
    if [[ ! -d "/Applications/T3 Code (Beta).app" ]]; then
      log_warn "T3 Code isn't installed; dotfiles brew installs it"
      exit 0
    fi
    ;;
  Linux)
    if [[ ! -f $HOME/.local/share/t3code/T3-Code.AppImage ]]; then
      if command -v omarchy-install-ai-t3-code >/dev/null 2>&1; then
        omarchy-install-ai-t3-code stable --no-launch
      else
        log_warn "omarchy-install-ai-t3-code isn't available; install T3 Code from Omarchy's Install > AI menu"
        exit 0
      fi
    fi
    ;;
esac

# The installer's own link points into ~/.t3/runtime/versions
if [[ $(readlink "$T3" 2>/dev/null || true) == "$T3CODE_HOME/runtime/versions/"* ]]; then
  log_item "t3 CLI $("$T3" --version 2>/dev/null | awk '{print $2}') (it updates with the app's update button or t3 update)"
else
  installer=$(mktemp "${TMPDIR:-/tmp}/dotfiles-t3-install.XXXXXX")
  trap 'rm -f "$installer"' EXIT
  if curl -fsSL --retry 3 "$INSTALLER" -o "$installer" && sh "$installer"; then
    log_success "t3 CLI installed into ~/.local/bin"
  else
    log_warn "Could not install the t3 CLI; rerun install/dotfiles/t3-code.sh, or: curl -fsSL $INSTALLER | sh"
    exit 0
  fi
fi

if [[ $(uname -s) == "Darwin" && -f $T3CODE_HOME/userdata/themes/omarchy.json ]]; then
  if "$T3" theme set omarchy --base-dir "$T3CODE_HOME" >/dev/null 2>&1; then
    log_item "T3 Code shows the omarchy theme"
  else
    log_warn "Could not select T3 Code's omarchy theme; pick Omarchy in its appearance settings"
  fi
fi

# The service keeps the PATH it was installed from, so it's installed from a
# fresh login shell's: the one ~/.zprofile (or Omarchy's /etc/profile.d) builds,
# with Homebrew and the mise shims the agents run through, rather than whatever
# the calling shell had picked up, such as one agent session's plugin folders.
if "$T3" service status 2>/dev/null | grep -q "not installed"; then
  if env PATH=/usr/bin:/bin:/usr/sbin:/sbin "${SHELL:-/bin/bash}" -lc '"$0" service install' "$T3"; then
    log_success "T3 Code's background service installed"
  else
    log_warn "T3 Code's service didn't install; see t3 service status"
  fi
else
  log_item "T3 Code's background service installed"
fi
