#!/usr/bin/env bash
# Finds and removes the copies of coding agents installed before mise took them
# over (stow/macos/.config/mise/conf.d/agents.toml): Homebrew's casks and
# formulae, and Claude Code's and Grok's native installers. mise's copy comes
# first on PATH, so these only cost disk and brew upgrades, until a shell that
# skips mise's activation runs one, out of date.
#
# A copy goes only once mise has a shim for the same command, so a machine that
# hasn't stowed agents.toml yet keeps its agents. claude and codex are single
# binaries a running session already holds, so they go even while in use.
# opencode and gemini run on node and load modules from disk as they go, so a
# formula whose command is running waits for a run with it closed.
#
# Sourced by `dotfiles brew` and `dotfiles doctor`.

# kind, Homebrew name (or the native installer's), command
AGENT_COPIES=(
  "cask claude-code claude"
  "cask codex codex"
  "cask cursor-cli cursor-agent"
  "formula opencode opencode"
  "formula gemini-cli gemini"
  "native claude claude"
  "native grok grok"
)

# Prints each copy still installed whose command mise also provides
agent_copies_found() {
  local shims="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims"
  local casks formulae entry kind name command
  casks=$(brew list --cask -1 2>/dev/null)
  formulae=$(brew list --formula -1 2>/dev/null)
  for entry in "${AGENT_COPIES[@]}"; do
    read -r kind name command <<<"$entry"
    [[ -x "$shims/$command" ]] || continue
    case $kind in
      cask) grep -qx "$name" <<<"$casks" || continue ;;
      formula) grep -qx "$name" <<<"$formulae" || continue ;;
      native)
        case $name in
          claude) [[ "$(readlink "$HOME/.local/bin/$command")" == "$HOME/.local/share/claude/versions/"* ]] || continue ;;
          # The rest of ~/.grok is Grok's config and sign-in, which mise's copy uses
          grok) [[ -d $HOME/.grok/downloads ]] || continue ;;
        esac
        ;;
    esac
    echo "$entry"
  done
}

agent_copies_remove() {
  local prefix kind name command
  prefix=$(brew --prefix)
  while read -r kind name command; do
    [[ -n $kind ]] || continue
    case $kind in
      cask)
        echo "==> Removing Homebrew's $name cask; mise provides $command"
        brew uninstall --cask "$name" || echo "==> Couldn't remove the $name cask; continuing"
        ;;
      formula)
        if pgrep -f "$prefix/(bin/$command|Cellar/$name/)" >/dev/null; then
          echo "==> Homebrew's $name is running; it's removed once it's closed"
          continue
        fi
        echo "==> Removing Homebrew's $name; mise provides $command"
        brew uninstall "$name" || echo "==> Couldn't remove the $name formula; continuing"
        ;;
      native)
        case $name in
          claude)
            echo "==> Removing Claude Code's native install; mise provides $command"
            rm -f "$HOME/.local/bin/$command"
            rm -rf "$HOME/.local/share/claude/versions"
            ;;
          grok)
            echo "==> Removing Grok's native install; mise provides $command"
            rm -rf "$HOME/.grok/bin" "$HOME/.grok/downloads" "$HOME/.grok/completions"
            ;;
        esac
        ;;
    esac
  done < <(agent_copies_found)
  return 0
}
