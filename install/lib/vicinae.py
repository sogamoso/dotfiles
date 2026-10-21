#!/usr/bin/env python3
"""Keep Vicinae's settings and store extensions in step with the repo.

Vicinae rewrites ~/.config/vicinae/settings.json whenever a setting changes in
its GUI, replacing the file rather than writing through a link, so the repo
can't own that file. It owns dotfiles.json, which settings.json imports, and
extensions.txt, one store extension per line. Anything the GUI writes lands in
settings.json; `save` moves it into the repo and `reset` throws it away.

Run through `dotfiles vicinae` and install/macos/vicinae.sh, not directly.

  status   list settings and extensions that differ from the repo; exit 1 if any
  save     keep them: merge settings into dotfiles.json, record extensions
  reset    discard them: drop local settings, sync extensions to the list
  install  install listed extensions that are missing, touching nothing else
"""
import json
import re
import shutil
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
REPO_CONFIG = REPO / "stow/macos/.config/vicinae"
SHARED = REPO_CONFIG / "dotfiles.json"
EXTENSIONS = REPO_CONFIG / "extensions.txt"
SETTINGS = Path.home() / ".config/vicinae/settings.json"
EXT_DIR = Path.home() / ".local/share/vicinae/extensions"

# The Raycast store turns away urllib's default User-Agent with a 403
HEADERS = {"User-Agent": "dotfiles-vicinae"}
BASE = {"$schema": "https://vicinae.com/schemas/config.json", "imports": [SHARED.name]}
# Keys Vicinae writes that say nothing about how it's used
IGNORED = {"$schema", "imports"}


def load_jsonc(path):
    """Vicinae writes JSON with comments and allows trailing commas."""
    text = re.sub(
        r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/',
        lambda m: m.group(0) if m.group(0).startswith('"') else "",
        path.read_text(),
        flags=re.S,
    )
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", text))


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")


def local_settings():
    if not SETTINGS.exists():
        return {}
    return {k: v for k, v in load_jsonc(SETTINGS).items() if k not in IGNORED}


def differences(local, shared, prefix=""):
    """Paths of the settings in local that shared doesn't already set the same way."""
    for key, value in local.items():
        path = f"{prefix}.{key}" if prefix else key
        if isinstance(value, dict) and value and isinstance(shared.get(key), dict):
            yield from differences(value, shared[key], path)
        elif shared.get(key, object()) != value:
            yield path


def merge(into, update):
    for key, value in update.items():
        if isinstance(value, dict) and isinstance(into.get(key), dict):
            merge(into[key], value)
        else:
            into[key] = value
    return into


def listed():
    if not EXTENSIONS.exists():
        return set()
    lines = (line.split("#")[0].strip() for line in EXTENSIONS.read_text().splitlines())
    return {line for line in lines if line}


def installed():
    """Store extensions on disk, keyed as store:handle/name like extensions.txt."""
    found = {}
    for path in EXT_DIR.glob("store.*.*"):
        store = path.name.split(".")[1]
        try:
            package = json.loads((path / "package.json").read_text())
        except (OSError, ValueError):
            continue
        author = package.get("author")
        author = author.get("name") if isinstance(author, dict) else author
        # Raycast's store files an extension under its owning org when it has one
        handle = (package.get("owner") or author) if store == "raycast" else author
        found[f"{store}:{handle}/{package['name']}"] = path
    return found


def fetch(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=60)


def download_url(ext):
    store, handle_name = ext.split(":", 1)
    if store == "vicinae":
        return f"https://api.vicinae.com/v1/store/{handle_name}/download"
    if store == "raycast":
        with fetch(f"https://backend.raycast.com/api/v1/extensions/{handle_name}") as r:
            return json.load(r)["download_url"]
    raise ValueError(f"unknown store {store!r}")


def install(ext):
    store, handle_name = ext.split(":", 1)
    target = EXT_DIR / f"store.{store}.{handle_name.split('/')[1]}"
    with tempfile.TemporaryDirectory() as tmp:
        archive = Path(tmp) / "extension.zip"
        with fetch(download_url(ext)) as r:
            archive.write_bytes(r.read())
        unpacked = Path(tmp) / "unpacked"
        with zipfile.ZipFile(archive) as z:
            z.extractall(unpacked)
        entries = list(unpacked.iterdir())
        root = entries[0] if len(entries) == 1 and entries[0].is_dir() else unpacked
        if not (root / "package.json").exists():
            raise RuntimeError("archive has no package.json")
        EXT_DIR.mkdir(parents=True, exist_ok=True)
        shutil.rmtree(target, ignore_errors=True)
        shutil.move(str(root), target)


def install_missing():
    have = installed()
    failed = 0
    for ext in sorted(listed() - have.keys()):
        try:
            install(ext)
            print(f"  + {ext}")
        except Exception as e:  # one bad listing shouldn't stop the rest
            print(f"  ✗ {ext}: {e}")
            failed += 1
    return failed


def drift():
    have = installed().keys()
    settings = list(differences(local_settings(), load_jsonc(SHARED)))
    return settings, sorted(have - listed()), sorted(listed() - have)


def cmd_status():
    settings, extra, missing = drift()
    for path in settings:
        print(f"  setting changed here: {path}")
    for ext in extra:
        print(f"  extension installed here, not in the repo: {ext}")
    for ext in missing:
        print(f"  extension in the repo, not installed: {ext}")
    return 1 if settings or extra or missing else 0


def cmd_save():
    settings = local_settings()
    if settings:
        write_json(SHARED, merge(load_jsonc(SHARED), settings))
    write_json(SETTINGS, BASE)
    EXTENSIONS.write_text("".join(f"{ext}\n" for ext in sorted(installed())))
    print(f"Saved to {SHARED.parent.relative_to(REPO)}/ — review and commit with git")
    return 0


def cmd_reset():
    write_json(SETTINGS, BASE)
    keep = listed()
    for ext, path in sorted(installed().items()):
        if ext not in keep:
            shutil.rmtree(path)
            print(f"  - {ext}")
    return 1 if install_missing() else 0


def cmd_install():
    if not SETTINGS.exists():
        SETTINGS.parent.mkdir(parents=True, exist_ok=True)
        write_json(SETTINGS, BASE)
    return 1 if install_missing() else 0


COMMANDS = {"status": cmd_status, "save": cmd_save, "reset": cmd_reset, "install": cmd_install}

if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:
        print(f"Usage: {Path(sys.argv[0]).name} {{{'|'.join(COMMANDS)}}}", file=sys.stderr)
        sys.exit(64)
    sys.exit(COMMANDS[sys.argv[1]]())
