#!/usr/bin/env bash
set -euo pipefail

# Grok's config stays Grok's: it holds the marketplace, the approval mode and
# the privacy acknowledgement, and Grok rewrites it. Omarchy themes an agent by
# applying one setting and leaving the rest of the file alone, which is what
# opencode.sh does. Grok's themes are built into the binary, so there is no
# colors.toml template to render; the setting is the theme name. Tokyo Night is
# the only theme here, and the one Omarchy ships as its default.
#
# permission_mode = "auto" makes auto mode Grok's default, as Claude Code's
# defaultMode = "auto" does there. Grok also reads that Claude setting, but
# its own key keeps working if Claude compatibility is ever turned off.
config="$HOME/.grok/config.toml"

mkdir -p "$(dirname "$config")"
[[ -f $config ]] || : >"$config"

python3 - "$config" <<'PY'
import os
import sys
import tempfile

path = sys.argv[1]
with open(path) as fh:
    lines = fh.read().splitlines(keepends=True)
if lines and not lines[-1].endswith("\n"):
    lines[-1] += "\n"

# Each setting with the values that already count as it
wants = [
    ("theme", "tokyonight", {"tokyonight", "tokyo-night", "tokyo"}),
    ("permission_mode", "auto", {"auto"}),
]


def scan():
    section = None
    ui_at = ui_end = None
    keys = {}
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("[["):
            if section == "ui" and ui_end is None:
                ui_end = i
            section = None
            continue
        if stripped.startswith("[") and stripped.endswith("]"):
            if section == "ui" and ui_end is None:
                ui_end = i
            section = stripped[1:-1].strip()
            if section == "ui":
                ui_at = i
            continue
        if section == "ui":
            keys[stripped.split("=", 1)[0].strip()] = i
    return ui_at, ui_end, keys


changed = False
for key, value, accepted in wants:
    want = f'{key} = "{value}"\n'
    ui_at, ui_end, keys = scan()
    if key in keys:
        current = lines[keys[key]].split("=", 1)[1].strip().strip("\"'")
        if current in accepted:
            continue
        lines[keys[key]] = want
    elif ui_at is not None:
        insert_at = ui_end if ui_end is not None else len(lines)
        while insert_at > ui_at + 1 and lines[insert_at - 1].strip() == "":
            insert_at -= 1
        lines.insert(insert_at, want)
    else:
        if lines and lines[-1].strip():
            lines.append("\n")
        lines.append("[ui]\n")
        lines.append(want)
    changed = True

if not changed:
    sys.exit(0)

mode = os.stat(path).st_mode & 0o777
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or ".")
try:
    with os.fdopen(fd, "w") as fh:
        fh.writelines(lines)
    os.chmod(tmp, mode or 0o644)
    os.replace(tmp, path)
except Exception:
    os.unlink(tmp)
    raise
PY
