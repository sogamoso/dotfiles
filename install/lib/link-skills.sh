#!/usr/bin/env bash
# Sourced by skills.sh after log.sh — never run directly.

# Names linked so far in this run, so a second source can't quietly take over a
# name the first one already answers to.
SKILLS_CLAIMED=""

# Names this repo refuses to shadow, set by the caller. A source that wants one
# gets its skill linked under a prefix instead. The list is explicit rather than
# discovered because what is installed differs per machine, and a dotfiles repo
# that produced different skill names on different machines would defeat itself.
SKILLS_RESERVED="${SKILLS_RESERVED:-}"

# Base names of the plugin skills on disk, filled on first use. Used only to
# report a collision the reserved list doesn't cover — never to decide what gets
# linked, for the same reproducibility reason.
PLUGIN_SKILL_NAMES=""

load_plugin_skill_names() {
  [[ -n $PLUGIN_SKILL_NAMES ]] && return 0
  local f
  while IFS= read -r f; do
    PLUGIN_SKILL_NAMES="$PLUGIN_SKILL_NAMES $(basename "$(dirname "$f")")"
  done < <(find "$HOME/.claude/plugins" -name SKILL.md -not -path '*/.git/*' 2>/dev/null)
  PLUGIN_SKILL_NAMES="${PLUGIN_SKILL_NAMES:- }"
}

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
# LINK_SKILLS_EXCLUDE skips a category directory; LINK_SKILLS_PREFIX names the
# source, used when a reserved name forces a rename.
link_skills() {
  local source_dir=$1 label=$2
  local exclude="${LINK_SKILLS_EXCLUDE:-}"
  local prefix="${LINK_SKILLS_PREFIX:-}"
  local skill_md skill_dir name link_name target dest stamp linked=0 conflicts=0

  [[ -d $source_dir ]] || return 0
  stamp=$(date +%s)
  load_plugin_skill_names

  while IFS= read -r skill_md; do
    skill_dir=$(dirname "$skill_md")
    name=$(basename "$skill_dir")
    [[ -n $exclude && $skill_dir == *"/$exclude/"* ]] && continue
    # Sources keep scaffolding alongside the real thing; a leading _ or . marks
    # it. Linking a template gives the agent a skill whose description is a
    # placeholder telling it what to write.
    case $name in _*|.*) continue ;; esac

    link_name=$name
    if [[ " $SKILLS_RESERVED " == *" $name "* ]]; then
      if [[ -z $prefix ]]; then
        log_warn "$label: '$name' is reserved and this source has no prefix, skipping"
        conflicts=$((conflicts + 1))
        continue
      fi
      link_name="$prefix-$name"
      log_item "$label: '$name' is reserved, linked as '$link_name'"
    elif [[ " $PLUGIN_SKILL_NAMES " == *" $name "* ]]; then
      log_warn "$label: '$name' also exists as a plugin skill and is not reserved"
    fi

    # Two sources offering one name is a real conflict: the agents key on the
    # name alone, so one of the skills would simply be unreachable. Keep the
    # first and say which lost rather than letting run order decide.
    if [[ " $SKILLS_CLAIMED " == *" $link_name "* ]]; then
      log_warn "$label: '$link_name' is already provided by an earlier source, skipping"
      conflicts=$((conflicts + 1))
      continue
    fi

    while IFS= read -r target; do
      mkdir -p "$target"
      dest="$target/$link_name"
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

    SKILLS_CLAIMED="$SKILLS_CLAIMED $link_name"
    linked=$((linked + 1))
  done < <(find "$source_dir" -name SKILL.md -not -path '*/.git/*' | sort)

  log_item "$label: $linked skill(s)"
  (( conflicts > 0 )) && log_warn "$label: $conflicts name conflict(s) skipped"
  return 0
}

# Drop links into the sources we manage that this run no longer produces —
# a skill renamed by the reserved list, dropped upstream, or moved between
# sources. Links pointing anywhere else are left alone.
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
