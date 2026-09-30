#!/usr/bin/env bash
# Sourced by skills.sh after log.sh — never run directly.

# Names linked so far in this run, so a second source can't quietly take over a
# name the first one already answers to.
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
# Set LINK_SKILLS_EXCLUDE to skip a category directory.
link_skills() {
  local source_dir=$1 label=$2
  local exclude="${LINK_SKILLS_EXCLUDE:-}"
  local skill_md skill_dir name target dest stamp linked=0 conflicts=0

  [[ -d $source_dir ]] || return 0
  stamp=$(date +%s)

  while IFS= read -r skill_md; do
    skill_dir=$(dirname "$skill_md")
    name=$(basename "$skill_dir")
    [[ -n $exclude && $skill_dir == *"/$exclude/"* ]] && continue
    # Sources keep scaffolding alongside the real thing; a leading _ or . marks
    # it. Linking a template gives the agent a skill whose description is a
    # placeholder telling it what to write.
    case $name in _*|.*) continue ;; esac

    # Two sources offering one name is a real conflict: the agents key on the
    # name alone, so one of the skills would simply be unreachable. Keep the
    # first and say which lost rather than letting run order decide.
    if [[ " $SKILLS_CLAIMED " == *" $name "* ]]; then
      log_warn "$label: '$name' is already provided by an earlier source, skipping"
      conflicts=$((conflicts + 1))
      continue
    fi

    while IFS= read -r target; do
      mkdir -p "$target"
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

    SKILLS_CLAIMED="$SKILLS_CLAIMED $name"
    linked=$((linked + 1))
  done < <(find "$source_dir" -name SKILL.md -not -path '*/.git/*' | sort)

  log_item "$label: $linked skill(s)"
  (( conflicts > 0 )) && log_warn "$label: $conflicts name conflict(s) skipped"
  return 0
}
