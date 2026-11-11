"""Runs Omarchy's Claude Code collector with the sign-in macOS keeps.

Omarchy's collector reads Claude Code's sign-in from ~/.claude/.credentials.json,
where the CLI keeps it on Linux. On macOS the CLI keeps it in the login
keychain, as "Claude Code-credentials", and leaves that file behind with
whatever token it last held: the limits stayed "paused" on a token weeks
old. This answers the collector's read of that one file from the keychain,
in this process only, and runs the collector unchanged, so it follows
Omarchy's updates. The token goes nowhere but the collector's limits probe.

Usage: claude-collector.py <omarchy-agent-usage-claude> [collector flags...]
"""

import json
import os
import runpy
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
import collectors  # noqa: E402

CREDENTIALS = Path.home() / ".claude" / ".credentials.json"
read_file = collectors.read_json


def keychain_login():
  try:
    raw = subprocess.check_output(
      ["/usr/bin/security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
      text=True, stderr=subprocess.DEVNULL, timeout=5,
    )
    data = json.loads(raw)
  except Exception:
    return None
  return data if isinstance(data, dict) else None


# The collector imports read_json from collectors, so replacing it here, before
# the collector runs, covers every read. Only the default home's credentials
# come from the keychain; any other path, or a keychain that can't be read,
# reads the file as before.
def read_json(path):
  if Path(path).expanduser() == CREDENTIALS:
    login = keychain_login()
    if login is not None:
      return login
  return read_file(path)


collectors.read_json = read_json
collector = sys.argv[1]
sys.argv = [collector, *sys.argv[2:]]
runpy.run_path(collector, run_name="__main__")
