#!/usr/bin/env bash
# Runs a prompt through the coding agent the Omarchy workflows use, unattended.
# The OMARCHY_AGENT repository variable picks it (claude or codex), and nothing
# here assumes one, so switching agents is a settings change.
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
claude_denied=(
  "Edit(.git/**)" "Write(.git/**)"
  "Edit(.github/**)" "Write(.github/**)"
  "Edit(.omarchy-upstream/**)" "Write(.omarchy-upstream/**)"
  # The process environment holds the agent's own token
  "Read(//proc/**)" "Grep(//proc/**)" "Glob(//proc/**)"
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
    npm install -g @openai/codex
    printenv OPENAI_API_KEY | codex login --with-api-key
    ;;
  claude:run)
    CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1 claude -p "${2:?run needs a prompt}" \
      --permission-mode acceptEdits --settings "$claude_settings" \
      --allowedTools "$(IFS=,; echo "${claude_tools[*]}")" \
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
