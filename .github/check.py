#!/usr/bin/env python3
"""Static checks for the conventions in AGENTS.md. Run from the repo root.

CI runs this on every push (.github/workflows/check.yml); it also runs locally.
Exits non-zero, listing every problem, if any check fails.
"""

import plistlib
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
problems = []

# Alias files that deliberately differ between zsh and bash; AGENTS.md says why
ALIAS_EXCEPTIONS = {"herdr", "tailscale"}


def fail(msg):
    problems.append(msg)


def tracked():
    out = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True, check=True).stdout
    return [ROOT / p for p in out.splitlines() if (ROOT / p).is_file()]


def shebang(path):
    try:
        with open(path, "rb") as f:
            first = f.readline().decode("utf-8", "replace").strip()
    except OSError:
        return ""
    return first if first.startswith("#!") else ""


def check_scripts(files):
    bash_scripts = []
    for path in files:
        rel = path.relative_to(ROOT)
        line = shebang(path)
        if line == "#!/bin/bash":
            fail(f"{rel}: use #!/usr/bin/env bash, not #!/bin/bash")
        if line.endswith("bash") or path.suffix == ".bash":
            bash_scripts.append(path)
            r = subprocess.run(["bash", "-n", path], capture_output=True, text=True)
            if r.returncode:
                fail(f"{rel}: bash syntax error\n{r.stderr.strip()}")
        elif path.suffix == ".zsh" and shutil.which("zsh"):
            r = subprocess.run(["zsh", "-n", path], capture_output=True, text=True)
            if r.returncode:
                fail(f"{rel}: zsh syntax error\n{r.stderr.strip()}")
    # Errors only: warnings would bury the real breakage under style noise
    if shutil.which("shellcheck"):
        r = subprocess.run(["shellcheck", "-S", "error", "-x", *bash_scripts], cwd=ROOT, capture_output=True, text=True)
        if r.returncode:
            fail(f"shellcheck errors:\n{r.stdout.strip()}")


def check_no_empty_files(files):
    """Nothing here is meant to be empty. An empty file is almost always a shell
    accident: pasted output containing `->host:port` runs as a redirect and
    creates one, which `git add -A` then commits."""
    for path in files:
        if path.stat().st_size == 0:
            fail(f"{path.relative_to(ROOT)}: empty file, probably created by accident")


def check_alias_pairs():
    zsh_dir = ROOT / "stow/zsh/.config/zsh/aliases"
    bash_dir = ROOT / "stow/linux/.config/bash/aliases"
    zsh = {p.stem: p for p in zsh_dir.glob("*.zsh")}
    bash = {p.stem: p for p in bash_dir.glob("*.bash")}
    for name in sorted(set(zsh) | set(bash)):
        if name in ALIAS_EXCEPTIONS:
            continue
        if name not in bash:
            fail(f"aliases/{name}.zsh has no bash counterpart (add it, or list it as an exception in AGENTS.md and here)")
        elif name not in zsh:
            fail(f"aliases/{name}.bash has no zsh counterpart")
        elif zsh[name].read_bytes() != bash[name].read_bytes():
            fail(f"aliases/{name}: zsh and bash copies differ; they must be byte-identical")


def check_launch_agents():
    stow_roots = [p for p in (ROOT / "stow").glob("*") if p.is_dir()]
    for plist in sorted((ROOT / "stow/macos/Library/LaunchAgents").glob("*.plist")):
        rel = plist.relative_to(ROOT)
        try:
            data = plistlib.loads(plist.read_bytes())
        except Exception as e:
            fail(f"{rel}: not a valid plist ({e})")
            continue
        if data.get("Label") != plist.stem:
            fail(f"{rel}: Label {data.get('Label')!r} doesn't match the file name")
        for arg in data.get("ProgramArguments", []):
            for ref in re.findall(r"\$HOME/([^\"' ]+)", arg):
                if not any((root / ref).exists() for root in stow_roots):
                    fail(f"{rel}: runs $HOME/{ref}, which no stow package provides")


BREWFILE_ENTRY = re.compile(r'^(tap|brew|cask) "([^"]+)"(.*)$')
BREWFILE_KINDS = ["tap", "brew", "cask"]


def check_brewfile():
    """Taps, then formulae, then casks, each block sorted, so a new entry has
    one right place and a duplicate sits next to its twin. Every tap carries
    `trusted: true` (brew-trust.sh says why), and every tap-qualified name
    needs its tap declared, since only declared taps get trusted."""
    taps, seen, prev = {}, set(), None
    for n, line in enumerate((ROOT / "Brewfile").read_text().splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        m = BREWFILE_ENTRY.match(line)
        if not m:
            fail(f"Brewfile:{n}: expected tap, brew or cask with a double-quoted name: {line}")
            continue
        kind, name, rest = m.groups()
        key = (kind, name.lower())
        if key in seen:
            fail(f"Brewfile:{n}: {kind} {name!r} is listed twice")
        seen.add(key)
        if kind == "tap":
            taps[name.lower()] = n
            if "trusted: true" not in rest:
                fail(f"Brewfile:{n}: tap {name!r} needs `trusted: true`")
        elif name.count("/") == 2 and name.rsplit("/", 1)[0].lower() not in taps:
            fail(f"Brewfile:{n}: {name!r} comes from a tap the Brewfile doesn't declare")
        if prev:
            order = (BREWFILE_KINDS.index(kind), name.lower())
            prev_order = (BREWFILE_KINDS.index(prev[0]), prev[1].lower())
            if order < prev_order:
                fail(f"Brewfile:{n}: {kind} {name!r} is out of order (after {prev[0]} {prev[1]!r})")
        prev = (kind, name)


MODS = {"alt": "option", "cmd": "cmd", "ctrl": "ctrl", "shift": "shift"}
KEYS = {
    **{str(n): "1-9" for n in range(1, 10)},
    **{k: "arrows" for k in ("left", "right", "up", "down")},
    "minus": "- / =", "equal": "- / =",
    "forwardDelete": "del", "slash": "/", "comma": ",", "esc": "escape", "backtick": "grave",
}


def check_hotkeys_documented():
    """Every AeroSpace binding needs a row in the README's hotkey tables."""
    toml = (ROOT / "stow/macos/.config/aerospace/aerospace.toml").read_text()
    section = re.search(r"^\[mode\.main\.binding\]\n(.*?)(?=^\[)", toml, re.S | re.M)
    if not section:
        fail("aerospace.toml: no [mode.main.binding] section found")
        return
    readme = (ROOT / "README.md").read_text()
    documented = set()
    for cell in re.findall(r"^\| `([^`]+)` \|", readme, re.M):
        documented.add(frozenset(t.strip().lower() for t in cell.split(" + ")))
        documented.add(cell.lower())
    for binding in re.findall(r"^([A-Za-z0-9-]+)\s*=", section.group(1), re.M):
        parts = binding.split("-")
        mods = [MODS[p] for p in parts[:-1] if p in MODS]
        key = parts[-1]
        if re.fullmatch(r"f\d+", key):
            if f"({key})" not in readme.lower():
                fail(f"aerospace.toml: {binding} isn't in the README hotkey tables")
            continue
        # A row can name the key itself (Cmd + Shift + 3) or the group it's in
        # (Option + 1-9), so either form counts
        tokens = {key.lower(), KEYS.get(key, key.lower())}
        if not any(frozenset(mods + [t]) in documented for t in tokens):
            fail(f"aerospace.toml: {binding} isn't in the README hotkey tables")


def main():
    files = tracked()
    check_scripts(files)
    check_no_empty_files(files)
    check_alias_pairs()
    check_launch_agents()
    check_brewfile()
    check_hotkeys_documented()
    if problems:
        print(f"{len(problems)} problem(s):\n")
        print("\n\n".join(f"✗ {p}" for p in problems))
        sys.exit(1)
    print("All checks passed")


if __name__ == "__main__":
    main()
