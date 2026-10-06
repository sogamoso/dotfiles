#!/usr/bin/env bash
# Sourced by skills.sh after log.sh — never run directly.

# Names linked so far in this run, so pruning knows which links are still wanted.
SKILLS_CLAIMED=""

# Claude Code and Codex both read <skills-dir>/<name>/SKILL.md, so one checkout
# serves both agents and the two stay in step by construction. Only link into an
# agent that is actually set up, so a machine with just one of them doesn't grow
# a config directory for the other.
skill_targets() {
  local target
  for target in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    [[ -d "$(dirname "$target")" ]] && echo "$target"
  done
}

# Link every skill under a source tree into each agent. Sources nest skills
# under category directories to taste, so find them by their SKILL.md and
# flatten on the directory name — that name is what both agents key on.
link_skills() {
  local source_dir=$1 label=$2
  local skill_md skill_dir name target dest stamp made linked=0

  # No agent directory means nothing to link into, and counting skills we walked
  # past would report a successful install that placed nothing. Bootstrap stows
  # before it gets here, so this is the standalone-run case.
  if [[ -z "$(skill_targets)" ]]; then
    log_warn "$label: neither ~/.claude nor ~/.codex exists, nothing linked"
    return 0
  fi

  [[ -d $source_dir ]] || return 0
  stamp=$(date +%s)

  while IFS= read -r skill_md; do
    skill_dir=$(dirname "$skill_md")
    name=$(basename "$skill_dir")
    # Sources keep scaffolding alongside the real thing; a leading _ or . marks
    # it. Linking a template gives the agent a skill whose description is a
    # placeholder telling it what to write.
    case $name in _*|.*) continue ;; esac

    made=0
    while IFS= read -r target; do
      mkdir -p "$target"
      made=1
      dest="$target/$name"
      if [[ -L $dest ]]; then
        [[ "$(readlink "$dest")" == "$skill_dir" ]] && continue
        rm "$dest"
      elif [[ -d $dest ]] && [[ -z "$(ls -A "$dest")" ]]; then
        # An empty directory is what stow leaves behind when a skill stops being
        # stowed. Nothing to preserve.
        rmdir "$dest"
      elif [[ -e $dest ]]; then
        # Not ours — ui.sh writes a real SKILL.md for the skills it serves over
        # MCP. Keep it in case it held something, but let the checkout win so a
        # rerun is not a no-op.
        mv "$dest" "$dest.bak.$stamp"
        log_item "Moved $dest aside to $dest.bak.$stamp"
      fi
      ln -s "$skill_dir" "$dest"
    done < <(skill_targets)

    (( made )) || continue
    SKILLS_CLAIMED="$SKILLS_CLAIMED $name"
    linked=$((linked + 1))
  done < <(find "$source_dir" -name SKILL.md -not -path '*/.git/*' | sort)

  log_item "$label: $linked skill(s)"
  return 0
}

# A source packaged as a plugin for BOTH agents is installed rather than linked:
# plugins namespace their skills and each agent updates them natively. Packaged
# for one agent only, it would namespace on that side and not the other, so it
# stays linked; a set you only use in that one agent belongs with its plugins
# instead, the way mattpocock sits in claude-code.sh. Prints PLUGIN@MARKETPLACE.
skill_plugin_id() {
  local dir=$1
  [[ -f "$dir/.claude-plugin/marketplace.json" ]] || return 1
  [[ -f "$dir/.agents/plugins/marketplace.json" ]] || return 1
  python3 -c '
import json, sys
d = json.load(open(sys.argv[1]))
plugins = d.get("plugins") or []
market = d.get("name")
if not plugins or not market or not plugins[0].get("name"):
    sys.exit(1)
print(plugins[0]["name"] + "@" + market)
' "$dir/.claude-plugin/marketplace.json" 2>/dev/null
}

# Read access over https, so neither agent needs an SSH agent unlocked just to
# fetch skills. Pushing still goes through the checkout's own remote.
to_https() {
  local url=$1
  [[ $url == git@* ]] || { printf '%s\n' "$url"; return 0; }
  url=${url#git@}
  printf 'https://%s/%s\n' "${url%%:*}" "${url#*:}"
}

# Point a marketplace at its URL, replacing an entry that resolves somewhere
# else. Sourcing by URL rather than by local path is what lets the skills work
# on a machine that never cloned the repo; an entry left pointing at a checkout
# would break there.
register_marketplace() {
  local tool=$1 name=$2 url=$3 out
  out=$("$tool" plugin marketplace add "$url" 2>&1) && return 0
  case $out in
    *"different source"*|*"already"*)
      "$tool" plugin marketplace remove "$name" >/dev/null 2>&1 || true
      "$tool" plugin marketplace add "$url" >/dev/null || return 1
      return 0
      ;;
  esac
  return 1
}

# Register the marketplace and install the plugin on each agent present. Every
# step is idempotent, so a rerun is a no-op rather than a reinstall.
install_skill_plugin() {
  local dir=$1 label=$2 url=$3 id marketplace failed=""
  id=$(skill_plugin_id "$dir") || return 1
  marketplace="${id#*@}"
  url=$(to_https "$url")

  # Claude declares its marketplaces in settings.json, which this repo stows, and
  # refuses to let the CLI override a declaration. So adding is only useful on a
  # machine where that file isn't in place yet; a refusal means the declaration
  # already won. Judge success by whether the plugin installs, not by the add.
  if command -v claude &>/dev/null; then
    claude plugin marketplace add "$url" >/dev/null 2>&1 || true
    claude plugin install "$id" >/dev/null || failed="$failed claude"
  fi
  if command -v codex &>/dev/null; then
    if register_marketplace codex "$marketplace" "$url"; then
      codex plugin add "$id" >/dev/null || failed="$failed codex"
    else
      failed="$failed codex"
    fi
  fi

  if [[ -n $failed ]]; then
    log_warn "$label: plugin $id failed on:$failed"
  else
    log_item "$label: installed as plugin $id"
  fi
  return 0
}

# Drop links into the sources we manage that this run no longer produces —
# a skill renamed, deleted, or moved to a plugin. Links pointing anywhere else
# are left alone.
prune_skill_links() {
  local target link root resolved managed pruned=0
  while IFS= read -r target; do
    for link in "$target"/*; do
      [[ -L $link ]] || continue
      resolved="$(readlink "$link")"
      managed=0
      for root in "$@"; do
        [[ -n $root && $resolved == "$root"/* ]] && managed=1
      done
      (( managed )) || continue
      [[ " $SKILLS_CLAIMED " == *" $(basename "$link") "* ]] && continue
      rm "$link"
      pruned=$((pruned + 1))
    done
  done < <(skill_targets)
  (( pruned > 0 )) && log_item "Removed $pruned link(s) no longer provided by any source"
  return 0
}
