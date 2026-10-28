#!/usr/bin/env bash
# Runs a prompt through the coding agent the Omarchy workflows use, unattended.
# The OMARCHY_AGENT repository variable picks it (claude or codex), and nothing
# here assumes one, so switching agents is a settings change. Each agent reads
# its own repository secret, and only the current agent's needs to be set:
#
#   claude  CLAUDE_CODE_OAUTH_TOKEN, from `claude setup-token`
#   codex   OPENAI_API_KEY
#
# To switch, set the new agent's secret (gh prompts for the value, keeping it
# out of shell history), then the variable, and delete the old secret:
#
#   gh secret set OPENAI_API_KEY --repo sogamoso/dotfiles
#   gh variable set OMARCHY_AGENT --body codex --repo sogamoso/dotfiles
#   gh secret delete CLAUDE_CODE_OAUTH_TOKEN --repo sogamoso/dotfiles
#
# The agent reads Omarchy's commits, which are third-party input, so it gets no
# network tools and runs no code from the repo. The workflow fetches what it
# needs beforehand (the review report and a clone of Omarchy in
# .omarchy-upstream/), and does everything that runs repo code itself, after
# this step and without the agent's credentials.
#
# Usage: omarchy-agent.sh install
#        omarchy-agent.sh run <prompt>
set -euo pipefail

agent=${OMARCHY_AGENT:?Set the OMARCHY_AGENT repository variable to claude or codex}

# Claude may read and edit files, read the Omarchy clone and this repo's history
# with git, run the parse-only checks, and commit locally. check.py only parses
# files, and the agent can't change it or anything else the workflow runs.
claude_tools=(
  Read Edit Write Glob Grep
  "Bash(git -C .omarchy-upstream log:*)" "Bash(git -C .omarchy-upstream show:*)"
  "Bash(git -C .omarchy-upstream diff:*)" "Bash(git -C .omarchy-upstream ls-tree:*)"
  "Bash(python3 .github/check.py)" "Bash(bash -n:*)" "Bash(zsh -n:*)"
  "Bash(diff:*)" "Bash(cmp:*)"
  "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)"
  "Bash(git add:*)" "Bash(git rm:*)" "Bash(git mv:*)" "Bash(git commit:*)"
)
# An Edit rule covers every file-editing tool and a Read rule every reading one,
# including paths a shell command names; Write and Glob rules match nothing
claude_denied=(
  "Edit(.git/**)" "Edit(.github/**)" "Edit(.omarchy-upstream/**)"
  # The process environment holds the agent's own token
  "Read(//proc/**)"
)

# Claude's shell commands run in its sandbox: no network, writes only in the
# checkout, no /proc, so no command can read Claude's own environment, and
# failIfUnavailable stops the run rather than going on unconfined. The tools'
# environment is scrubbed of credentials too.
claude_settings='{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false,
    "autoAllowBashIfSandboxed": false,
    "filesystem": { "denyRead": ["/proc"] },
    "network": { "allowedDomains": [] }
  }
}'

case "$agent:${1:-}" in
  claude:install)
    npm install -g @anthropic-ai/claude-code
    # The sandbox's backend; Ubuntu's AppArmor blocks the user namespaces it needs
    sudo apt-get install -y --no-install-recommends bubblewrap socat
    sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
    ;;
  codex:install)
    : "${OPENAI_API_KEY:?Set the OPENAI_API_KEY repository secret}"
    npm install -g @openai/codex
    printenv OPENAI_API_KEY | codex login --with-api-key
    ;;
  claude:run)
    : "${CLAUDE_CODE_OAUTH_TOKEN:?Set the CLAUDE_CODE_OAUTH_TOKEN repository secret}"
    # Scrubbing forces the default permission mode, so only the tools listed
    # run; OMARCHY_AGENT_DEBUG adds Claude Code's debug log, which says whether
    # the sandbox started
    # OMARCHY_AGENT_PROBE_TOOLS adds tools for the sandbox check only
    CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1 claude -p "${2:?run needs a prompt}" \
      ${OMARCHY_AGENT_DEBUG:+--debug} --settings "$claude_settings" \
      --allowedTools "$(IFS=,; echo "${claude_tools[*]}")${OMARCHY_AGENT_PROBE_TOOLS:+,$OMARCHY_AGENT_PROBE_TOOLS}" \
      --disallowedTools "$(IFS=,; echo "${claude_denied[*]}")"
    ;;
  codex:run)
    # Commands run sandboxed: writes stay in the checkout and there's no
    # network. Codex's sandbox doesn't hide its own credentials file, though,
    # so the workflow's secret scan is the only check on that path
    codex exec --full-auto "${2:?run needs a prompt}"
    ;;
  *)
    echo "Usage: OMARCHY_AGENT=claude|codex $0 install | run <prompt>" >&2
    exit 64
    ;;
esac
