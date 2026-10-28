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
# Edit and Read rules cover every editing and reading tool, including paths a
# shell command names. Claude Code reports the Write, Grep and Glob rules as
# matching nothing today; they stay in case a later version applies them.
claude_denied=(
  "Edit(.git/**)" "Write(.git/**)"
  "Edit(.github/**)" "Write(.github/**)"
  "Edit(.omarchy-upstream/**)" "Write(.omarchy-upstream/**)"
  # The process environment holds the agent's own token, and Claude Code's own
  # files can hold it too
  "Read(//proc/**)" "Grep(//proc/**)" "Glob(//proc/**)"
  "Read(~/.claude/**)" "Grep(~/.claude/**)" "Glob(~/.claude/**)"
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
    "filesystem": { "denyRead": ["/proc", "~/.claude"] },
    "network": { "allowedDomains": [] }
  }
}'

case "$agent:${1:-}" in
  claude:install)
    npm install -g @anthropic-ai/claude-code
    # The sandbox's backend. Ubuntu's AppArmor blocks the user namespaces it
    # needs, and its bwrap profile strips capabilities from the nested one the
    # sandbox's seccomp helper creates; the runner is thrown away after the job
    sudo apt-get install -y --no-install-recommends bubblewrap socat
    sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
    for profile in /etc/apparmor.d/bwrap-userns-restrict /etc/apparmor.d/unprivileged_userns; do
      [[ -f $profile ]] && sudo apparmor_parser -R "$profile" 2>/dev/null || true
    done
    ;;
  codex:install)
    : "${OPENAI_API_KEY:?Set the OPENAI_API_KEY repository secret}"
    npm install -g @openai/codex
    printenv OPENAI_API_KEY | codex login --with-api-key
    ;;
  claude:run)
    : "${CLAUDE_CODE_OAUTH_TOKEN:?Set the CLAUDE_CODE_OAUTH_TOKEN repository secret}"
    # Scrubbing forces the default permission mode, so only the tools listed
    # run
    # OMARCHY_AGENT_PROBE grants the sandbox check's probe commands, exactly as
    # written, each writing its own output: hashing a value only a run command
    # can see, and two requests, one through the sandbox's proxy and one around it
    probe_tools=()
    if [[ -n ${OMARCHY_AGENT_PROBE:-} ]]; then
      probe_tools=(
        "Bash(git hash-object .omarchy-nonce > .omarchy-probe-run.txt)"
        "Bash(curl -sS -m 10 -o /dev/null -w %{http_code} https://example.com > .omarchy-probe-proxy.txt)"
        "Bash(curl -sS -m 10 --noproxy '*' -o /dev/null -w %{http_code} https://example.com > .omarchy-probe-direct.txt)"
      )
    fi
    allowed=("${claude_tools[@]}" "${probe_tools[@]}")
    CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1 claude -p "${2:?run needs a prompt}" \
      --settings "$claude_settings" \
      --allowedTools "$(IFS=,; echo "${allowed[*]}")" \
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
