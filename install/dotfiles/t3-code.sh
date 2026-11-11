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
# file is config/t3code/omarchy.json, Omarchy's t3code.json.tpl rendered for
# Tokyo Night, copied in here. Copied rather than stowed: T3 ignores a theme
# that is a symlink. It is written atomically, as Omarchy writes it, since T3
# watches the file and would read a half-written one as invalid.
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

if [[ $(uname -s) == "Darwin" ]]; then
  theme_src="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/config/t3code/omarchy.json"
  theme="$T3CODE_HOME/userdata/themes/omarchy.json"
  # A link left by the stow package this file used to be in
  [[ -L $theme ]] && rm -f "$theme"
  if ! cmp -s "$theme_src" "$theme"; then
    mkdir -p "$(dirname "$theme")"
    tmp=$(mktemp "$theme.XXXXXX")
    cp "$theme_src" "$tmp"
    mv "$tmp" "$theme"
  fi
  if "$T3" theme set omarchy --base-dir "$T3CODE_HOME" >/dev/null 2>&1; then
    log_item "T3 Code shows the omarchy theme"
  else
    log_warn "Could not select T3 Code's omarchy theme; pick Omarchy in its appearance settings"
  fi
fi

# One server per T3 home: the app's own and the service would both claim
# ~/.t3, and the app refuses to start ("This T3 home is unavailable"). As T3
# recommends for an app beside a service, the app's local environment is off
# (Settings > Environments) and the app works through the service, once
# paired with it (docs/macos-manual-setup.md). A running app keeps its own
# copy of this file and writes it back, so it takes effect when it reopens.
DESKTOP_SETTINGS="$T3CODE_HOME/userdata/desktop-settings.json"
if ! jq -e '.localEnvironmentEnabled == false' "$DESKTOP_SETTINGS" >/dev/null 2>&1; then
  mkdir -p "$(dirname "$DESKTOP_SETTINGS")"
  tmp=$(mktemp "$DESKTOP_SETTINGS.XXXXXX")
  jq '.localEnvironmentEnabled = false' "$DESKTOP_SETTINGS" >"$tmp" 2>/dev/null ||
    echo '{"localEnvironmentEnabled":false}' >"$tmp"
  mv "$tmp" "$DESKTOP_SETTINGS"
  if pgrep -x "T3 Code (Beta)" >/dev/null 2>&1 || pgrep -x t3code >/dev/null 2>&1; then
    log_warn "T3 Code is open; quit and reopen it so it uses the background service"
  else
    log_item "T3 Code's app uses the background service instead of a server of its own"
  fi
fi

# Each machine is reachable both ways: over the tailnet, and through T3
# Connect. The server listens on 127.0.0.1 only, where T3 Connect's tunnel
# reaches it, and publishes itself to the tailnet through Tailscale Serve
# (https://<machine>.<tailnet>.ts.net), which it sets up on every start. T3's
# LAN mode would reach the tailnet too, but by listening on every network the
# machine joins, café Wi-Fi included, so it stays off. Both are lines in
# service.env, written here rather than through `t3 up`, which restarts the
# service unasked when there's no terminal and stops running agent turns: a
# new service starts with them, a running one picks them up at its next restart.
SERVICE_ENV="$T3CODE_HOME/service.env"
SERVICE_SETTINGS=(T3CODE_LAN=false T3CODE_TAILSCALE_SERVE=true)
settings_on() {
  local setting
  for setting in "${SERVICE_SETTINGS[@]}"; do
    grep -qx "$setting" "$SERVICE_ENV" 2>/dev/null || return 1
  done
}
set_settings() {
  local tmp setting
  mkdir -p "$T3CODE_HOME"
  tmp=$(mktemp "$SERVICE_ENV.XXXXXX")
  grep -vE '^(T3CODE_LAN|T3CODE_TAILSCALE_SERVE)=' "$SERVICE_ENV" 2>/dev/null >"$tmp" || true
  for setting in "${SERVICE_SETTINGS[@]}"; do
    echo "$setting" >>"$tmp"
  done
  mv "$tmp" "$SERVICE_ENV"
}
settings_on || set_settings

# The service keeps the PATH it was installed from, so it's installed from a
# fresh login shell's: the one ~/.zprofile (or Omarchy's /etc/profile.d) builds,
# with Homebrew and the mise shims the agents run through, rather than whatever
# the calling shell had picked up, such as one agent session's plugin folders.
if "$T3" service status 2>/dev/null | grep -q "not installed"; then
  if env PATH=/usr/bin:/bin:/usr/sbin:/sbin "${SHELL:-/bin/bash}" -lc '"$0" service install' "$T3"; then
    log_success "T3 Code's background service installed"
    # Nothing runs on a service this new, so a restart costs nothing, should
    # the install have put back the default it writes for a new service
    if ! settings_on; then
      set_settings
      "$T3" service restart >/dev/null
    fi
  else
    log_warn "T3 Code's service didn't install; see t3 service status"
  fi
else
  log_item "T3 Code's background service installed"
fi

# T3 Connect needs a sign-in to a T3 account, once per machine, which only a
# person can approve. With a terminal, `t3 up --connect` asks before any
# restart; unattended runs, such as the daily update, only say what's left.
if ! "$T3" status --json 2>/dev/null | jq -e '.connect.enabled == true and .connect.revoked != true' >/dev/null; then
  if [[ -t 0 && -t 1 ]]; then
    "$T3" up --connect || log_warn "T3 Connect isn't set up; run: t3 up --connect"
  else
    log_warn "T3 Connect isn't set up; run t3 up --connect in a terminal to sign in"
  fi
fi
