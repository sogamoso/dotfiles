#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

# Third-party plugins for Codex — the counterpart of claude-code.sh.
# sogamoso-skills is installed by skills.sh, since it's the one plugin this
# repo owns.

if ! command -v codex &>/dev/null; then
  log_warn "Codex not installed, skipping plugin setup"
  exit 0
fi

# Auto-review by default, as Claude Code's defaultMode = "auto": approval
# requests go to Codex's reviewer instead of a prompt, inside the workspace-write
# sandbox. The same as --approve-for-me, which only covers sessions started with
# it, not a plain codex or a resumed one. config.toml stays Codex's, since it
# writes its plugin list there, so only these keys are set.
python3 - "$HOME/.codex/config.toml" <<'PY'
import os
import sys
import tempfile

path = sys.argv[1]
want = {
    "approval_policy": '"on-request"',
    "approvals_reviewer": '"auto_review"',
    "sandbox_mode": '"workspace-write"',
}

os.makedirs(os.path.dirname(path), exist_ok=True)
lines = open(path).read().splitlines(keepends=True) if os.path.exists(path) else []
if lines and not lines[-1].endswith("\n"):
    lines[-1] += "\n"

# Top-level keys only count before the first table
first_table = next((i for i, l in enumerate(lines) if l.lstrip().startswith("[")), len(lines))
insert_at = first_table
while insert_at > 0 and not lines[insert_at - 1].strip():
    insert_at -= 1
changed = False
for key, value in want.items():
    line = f"{key} = {value}\n"
    at = next((i for i in range(first_table) if lines[i].split("=", 1)[0].strip() == key), None)
    if at is None:
        lines.insert(insert_at, line)
        insert_at += 1
        first_table += 1
        changed = True
    elif lines[at] != line:
        lines[at] = line
        changed = True

if not changed:
    sys.exit(0)

mode = os.stat(path).st_mode & 0o777 if os.path.exists(path) else 0o600
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path))
try:
    with os.fdopen(fd, "w") as fh:
        fh.writelines(lines)
    os.chmod(tmp, mode)
    os.replace(tmp, path)
except Exception:
    os.unlink(tmp)
    raise
PY
log_success "Codex reviews its own approvals"

log_heading "Adding Codex marketplaces..."

marketplaces=(
  "https://github.com/anthropics/claude-plugins-official.git"
  "https://github.com/obra/superpowers-marketplace.git"
  "https://github.com/SawyerHood/dev-browser.git"
)

for marketplace in "${marketplaces[@]}"; do
  if codex plugin marketplace add "$marketplace" >/dev/null 2>&1; then
    log_item "$marketplace"
  else
    log_warn "Failed to add $marketplace"
  fi
done

log_heading "Installing Codex plugins..."

# Only plugins Codex can actually use. Ones that are only slash commands,
# subagents or Claude hooks (code-review, feature-dev, pr-review-toolkit,
# code-simplifier, security-guidance, hookify, plugin-dev) stay in claude-code.sh,
# as do the LSP plugins: Codex doesn't read a plugin's lspServers.
plugins=(
  "frontend-design@claude-plugins-official"
  "dev-browser@dev-browser-marketplace"
  "superpowers@superpowers-marketplace"
  "episodic-memory@superpowers-marketplace"
)

for plugin in "${plugins[@]}"; do
  if codex plugin add "$plugin" >/dev/null 2>&1; then
    log_item "$plugin"
  else
    log_warn "Failed to install $plugin"
  fi
done

log_success "Codex plugins installed"
