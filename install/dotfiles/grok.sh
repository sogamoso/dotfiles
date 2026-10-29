#!/usr/bin/env bash
set -euo pipefail

# Grok's config stays Grok's: it holds the marketplace, the approval mode and
# the privacy acknowledgement, and Grok rewrites it. Omarchy themes an agent by
# applying one setting and leaving the rest of the file alone, which is what
# opencode.sh does. Grok's themes are built into the binary, so there is no
# colors.toml template to render. The built-in Tokyo Night paints its own
# canvas, so the pane sits on the terminal's Tokyo Night instead
# (theme = "terminal"; transparent and native count). That name stays hidden,
# and a configured value falls back to GrokNight, until features.terminal_theme
# is on, so both are set.
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

# section, key, the line to write, and raw values that already count as it.
# The flag has to be a boolean: a quoted "true" would not enable the theme.
wants = [
    ("features", "terminal_theme", "terminal_theme = true\n", {"true"}),
    (
        "ui",
        "theme",
        'theme = "terminal"\n',
        {'"terminal"', '"terminal-default"', '"transparent"', '"native"'},
    ),
    ("ui", "permission_mode", 'permission_mode = "auto"\n', {'"auto"'}),
]


def rhs(line):
    return line.split("=", 1)[1].strip().split(" #", 1)[0].strip()


def scan():
    section = None
    spans = {}
    keys = {}
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("[["):
            if section in spans and spans[section][1] is None:
                spans[section][1] = i
            section = None
            continue
        if stripped.startswith("[") and stripped.endswith("]"):
            if section in spans and spans[section][1] is None:
                spans[section][1] = i
            section = stripped[1:-1].strip()
            spans.setdefault(section, [i, None])
            continue
        if section is None or "=" not in stripped or stripped.startswith("#"):
            continue
        key = stripped.split("=", 1)[0].strip()
        keys.setdefault((section, key), i)
    return spans, keys


changed = False
for section, key, want, accepted in wants:
    spans, keys = scan()
    found = keys.get((section, key))
    if found is not None:
        if rhs(lines[found]) in accepted:
            continue
        lines[found] = want
    elif section in spans:
        header, end = spans[section]
        insert_at = end if end is not None else len(lines)
        while insert_at > header + 1 and lines[insert_at - 1].strip() == "":
            insert_at -= 1
        lines.insert(insert_at, want)
    else:
        if lines and lines[-1].strip():
            lines.append("\n")
        lines.append(f"[{section}]\n")
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
