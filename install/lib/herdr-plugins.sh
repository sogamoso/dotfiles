#!/usr/bin/env bash
# Sourced by install/dotfiles/herdr-plugins.sh, herdr-integrations.sh,
# herdr-machines.sh, install/macos/tailscale.sh and `dotfiles doctor` — never
# run directly.

# Third-party herdr plugins, one per line: plugin id, GitHub source, pinned commit.
# The worktree plugin creates worktrees from a pull request, an issue or a
# branch, and is what prefix+u and the Ctrl-click on a pull request link open.
# The automatic rename plugin names each tab after its foreground program, as
# tmux's automatic-rename does, through the shell hook the supplements source.
HERDR_THIRD_PARTY_PLUGINS=(
  "worktree mkdir700/herdr-plugin-worktree 3d7ec281bc7e6a36850d99b2f15c35a3ed3f1359"
  "herdr-automatic-rename qu8n/herdr-automatic-rename a99754357fdea3119c430fd0cad822eef9047895"
)

# herdr's own agent integrations, installed by install/dotfiles/herdr-integrations.sh
HERDR_INTEGRATIONS=(claude codex cursor grok)

# The machine every other host saves in herdr, by its ~/.ssh/config host, and
# its Tailscale name, which tells install/dotfiles/herdr-machines.sh it's on it
HERDR_MACHINE="mac-mini"
HERDR_MACHINE_HOST="sogamoso-m4-mac-mini"

# herdr 0.9.5 never counts a server kept running by launchd as ready for saved
# machines (https://github.com/herdrdev/herdr/issues/4205), so the mini runs
# herdr's own background server instead of the brew service every other Mac
# keeps. `dotfiles doctor` says when the issue closes: then drop the
# on_herdr_machine_host branches in tailscale.sh, `dotfiles reload` and doctor.
HERDR_LAUNCHD_ISSUE=4205

# True on the mini itself, by its Tailscale name
on_herdr_machine_host() {
  local self
  self=$(tailscale status --self --json 2>/dev/null | jq -r '.Self.DNSName // empty' 2>/dev/null || true)
  [[ ${self%%.*} == "$HERDR_MACHINE_HOST" ]]
}
