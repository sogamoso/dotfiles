#!/usr/bin/env bash
# Sourced by install/macos/omarchy-agents.sh and `dotfiles doctor` — never run
# directly.

# The agents widget runs Omarchy's own usage collectors
# (bin/omarchy-agent-usage-* on shell/plugins/agents/collectors.py) from a
# sparse checkout of Omarchy at Omarchy's own path, so OMARCHY_PATH means the
# same thing on both machines. The collectors run as this user and read every
# agent's transcripts and sign-ins, so the checkout is pinned to a commit whose
# collectors were read first. Bump the pin only after reading what changed
# since; the weekly Omarchy review lists it.
OMARCHY_AGENTS_COMMIT=573b518be16ec47547d50fe6197bc7f53e982340
OMARCHY_AGENTS_DIR="$HOME/.local/share/omarchy"
OMARCHY_AGENTS_PATHS=(bin shell/plugins/agents docs)
# The collectors need Python 3.11 (tomllib); macOS ships 3.9, so Homebrew's,
# which is on SketchyBar's PATH
OMARCHY_AGENTS_PYTHON=/opt/homebrew/bin/python3
