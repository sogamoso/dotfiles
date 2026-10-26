#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# terminal-browser, which opens pull requests in herdr's popup (prefix+shift+u).
# On macOS the Brewfile's cask installs it; Omarchy has no Homebrew, so this
# does the cask's job: downloads the pinned release, checks it against the
# sha256 the cask publishes, and links its binary into ~/.local/bin. Pinned
# rather than latest, so a download is checked against a known sum; bump the
# version and both sums together, from the cask (Casks/t/terminal-browser.rb).

VERSION="0.13.4"

case "$(uname -m)" in
  x86_64) arch="x64"; sum="6277daaabab16711ab3f1961cdffad9efac5e70ac55d5076e2c86496d649d3a4" ;;
  aarch64 | arm64) arch="arm64"; sum="0cf567d8218995a24fb6ce4b06c07ccf58a8c517906058087355f1e2fad1969f" ;;
  *) log_warn "No terminal-browser build for $(uname -m)"; exit 0 ;;
esac

dest="$HOME/.local/share/terminal-browser/$VERSION"
bin="$dest/terminal-browser/bin/terminal-browser"

log_heading "Installing terminal-browser..."

if [[ -x $bin ]]; then
  log_item "terminal-browser $VERSION (up to date)"
else
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "https://terminal-browser.sh/install/dl/stable/v$VERSION/terminal-browser-linux-$arch.tar.gz" -o "$tmp/terminal-browser.tar.gz"
  if ! echo "$sum  $tmp/terminal-browser.tar.gz" | sha256sum --check --quiet; then
    log_warn "terminal-browser $VERSION didn't match its pinned sha256; not installed"
    exit 0
  fi
  mkdir -p "$dest"
  tar -xzf "$tmp/terminal-browser.tar.gz" -C "$dest"
  log_item "terminal-browser $VERSION"
fi

mkdir -p "$HOME/.local/bin"
ln -sfn "$bin" "$HOME/.local/bin/terminal-browser"
log_success "terminal-browser linked into ~/.local/bin"
