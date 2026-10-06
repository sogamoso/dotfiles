#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/link-skills.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OWN_URL="git@github.com:sogamoso/skills.git"
# Not SKILLS_DIR — that name is read by the skills repo's own install.sh as the
# symlink *target*, and would send skills into this checkout instead of ~/.claude/skills.
OWN_DIR="${SKILLS_REPO_DIR:-$HOME/Code/sogamoso/skills}"

# The ui.sh stubs live in a private repo: the ui.sh license forbids
# redistributing what it scaffolds, and this one is public.
UIDOTSH_URL="git@github.com:sogamoso/uidotsh-archive.git"
UIDOTSH_DIR="${UIDOTSH_ARCHIVE_DIR:-$HOME/Code/sogamoso/uidotsh-archive}"

# Both repos are private and cloned over SSH because they get pushed to, so a
# locked 1Password agent is a failure mode: BatchMode turns it into a fast
# failure instead of a bootstrap-blocking prompt, and accept-new does the same
# for the host key on a machine with no known_hosts yet.
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

log_heading "Installing agent skills..."

# Prefer the plugin route when the source supports it on both agents; fall back
# to linking otherwise. The packaging decides the mechanism, so a source that
# ships a Codex plugin later switches over on the next run without an edit here.
add_source() {
  local repo_dir=$1 link_dir=$2 label=$3 url=${4:-}
  install_skill_plugin "$repo_dir" "$label" "$url" && return 0
  link_skills "$link_dir" "$label"
}

# Keep a checkout current, or report why it isn't usable. Never fatal: skills
# are additive, and a locked keychain shouldn't cost the rest of bootstrap.
sync_checkout() {
  local url=$1 dir=$2 label=$3
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" pull --quiet --ff-only 2>/dev/null ||
      log_warn "$label: couldn't update $dir, using the existing checkout"
    return 0
  fi
  mkdir -p "$(dirname "$dir")"
  if git clone --quiet "$url" "$dir" 2>/dev/null; then
    log_item "$label: cloned into $dir"
    return 0
  fi
  log_warn "$label: couldn't clone $url, skipping"
  [[ $url == git@* ]] && log_item "Unlock 1Password and enable its SSH agent, then rerun bootstrap"
  return 1
}

# Ask ui.sh whether the license token still works: an MCP handshake, no skill
# fetched. Prints live (accepted), revoked (401/403: the subscription ended or
# the token changed) or unknown (no token, no network, server down — none of
# which says anything about the subscription).
uidotsh_access() {
  local token="${UIDOTSH_TOKEN:-}" env_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/uidotsh.env" code
  [[ -z $token && -r $env_file ]] && token="$(source "$env_file" && printf %s "${UIDOTSH_TOKEN:-}")"
  [[ -n $token ]] || { echo unknown; return; }
  # ui.sh rejects curl's and Python's default User-Agents. The token goes in
  # through a file descriptor so it never shows in the process list.
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X POST "${UIDOTSH_PROBE_URL:-https://ui.sh/mcp?agent=claude}" \
    -A "dotfiles-skills/1" -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
    -H @<(printf 'Authorization: Bearer %s\n' "$token") \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"dotfiles","version":"1"}}}' \
    2>/dev/null) || code=000
  case $code in
    200) echo live ;;
    401|403) echo revoked ;;
    *) echo unknown ;;
  esac
}

uidotsh_notify() {
  log_warn "$1"
  [[ -r $HOME/.config/dotfiles/lib/notify.sh ]] || return 0
  GROUP_ID="dotfiles-uidotsh"
  source "$HOME/.config/dotfiles/lib/notify.sh"
  notify "ui.sh skills" "$1"
}

# While ui.sh accepts the token, link the stubs, which fetch the current skills
# over MCP. Once it refuses the token, build offline copies from the archive's
# latest snapshot into local/ and link those instead; renewing switches back on
# the next run. When access can't be checked, keep whichever is in place.
if sync_checkout "$UIDOTSH_URL" "$UIDOTSH_DIR" "uidotsh-archive"; then
  local_dir="$UIDOTSH_DIR/local"
  case $(uidotsh_access) in
    live)
      if [[ -d $local_dir ]]; then
        rm -rf "$local_dir"
        uidotsh_notify "ui.sh accepts the token again; back on the live skills"
      fi
      ;;
    revoked)
      if [[ ! -d $local_dir ]]; then
        if python3 "$UIDOTSH_DIR/restore.py" >/dev/null; then
          uidotsh_notify "ui.sh refused the token; using the archived skills"
        else
          log_warn "ui.sh refused the token, and building the archived skills failed; keeping the stubs"
        fi
      fi
      ;;
    unknown)
      log_item "Couldn't check ui.sh access; keeping the current ui.sh skills"
      ;;
  esac

  if [[ -d $local_dir ]]; then
    link_skills "$local_dir" "ui.sh (archived)"
  else
    link_skills "$UIDOTSH_DIR/stubs" "ui.sh stubs"
  fi
fi

# Cloned because it's a repo you work in; the plugin itself comes from the URL,
# so the skills still land on a machine where the clone was skipped.
if sync_checkout "$OWN_URL" "$OWN_DIR" "sogamoso/skills"; then
  add_source "$OWN_DIR" "$OWN_DIR" "sogamoso/skills" "$OWN_URL"
  # Git won't enable a versioned hooks directory on its own, and the hook is
  # what enforces the repo's checks and version bumps.
  git -C "$OWN_DIR" config core.hooksPath .githooks
fi

# The plugin was renamed from sogamoso to sogamoso-skills; drop the old install
# so Codex doesn't load every skill twice and Claude doesn't keep a dead entry.
if command -v claude &>/dev/null; then
  claude plugin uninstall sogamoso@sogamoso >/dev/null 2>&1 || true
fi
if command -v codex &>/dev/null; then
  codex plugin remove sogamoso@sogamoso >/dev/null 2>&1 || true
fi

# The ui.sh stubs used to be linked from this repo's skills/, and mattpocock
# from a vendor checkout; listing both clears those links on machines that
# still have them.
prune_skill_links "$UIDOTSH_DIR/stubs" "$UIDOTSH_DIR/local" "$OWN_DIR" "$REPO_DIR/skills" "$HOME/Code/vendor/mattpocock-skills"

log_success "Agent skills installed"
