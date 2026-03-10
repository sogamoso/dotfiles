# macOS → Omarchy Setup — Manual Steps

Everything in this doc requires human interaction and can't be scripted.
The installer (`bootstrap`) handled the rest automatically.

---

## 1. Grant Accessibility Permissions

macOS requires manual approval for any app that controls input or windows.
Open each prompt as it appears during the install, or go here:

**System Settings → Privacy & Security → Accessibility**
- Karabiner-Elements
- Aerospace
- AltTab

> Karabiner-EventViewer may also appear here — it's a debug tool, leave it off.

**System Settings → Privacy & Security → Input Monitoring**
- Karabiner-Core-Service
- Karabiner-EventViewer

> After granting Karabiner permissions, log out and back in (or reboot) for the Cmd↔Ctrl swap to take effect.

---

## 2. Set Raycast Hotkey

After rebooting (post-Karabiner), physical Cmd+Space sends Ctrl+Space to macOS.
Set Raycast to respond to that:

System Settings → Keyboard → Keyboard Shortcuts — disable all shortcuts in these sections:

1. **Mission Control** — conflicts with AeroSpace workspace bindings after Karabiner swap
2. **App Shortcuts → Windows** — conflicts with AeroSpace window bindings
3. **Input Sources** — Globe key handles language switching instead
4. **Spotlight** — Raycast takes that slot

Then set Raycast as the launcher:

5. Open Raycast → Settings → General
6. Set **Raycast Hotkey** to `Ctrl+Space`

---

## 3. Slack Tokyo Night Theme

Slack → Preferences → Themes → Custom Theme → paste:

```
#1a1b26,#32344a,#7aa2f7,#a9b1d6,#444b6a,#a9b1d6,#9ece6a,#7aa2f7,#1a1b26,#a9b1d6
```

---

## Keybinding Reference

> Type `!keys` in Raycast to expand the cheatsheet anywhere.
> First-time setup: Raycast → Import Snippets → `~/.config/raycast/snippets.json`.

Physical Cmd = SUPER on Omarchy (Karabiner maps Cmd → Ctrl under the hood).


## Remaining Gaps vs Omarchy

| Omarchy | macOS |
|---|---|
| `SUPER + O` — float & pin | Float only via Cmd+T, no pin-on-top |
| `SUPER + SHIFT + SPACE` — toggle waybar | No SketchyBar hotkey toggle |
| `SUPER + mouse drag` — move/resize | Keyboard resize only |
| Per-monitor independent workspaces | Aerospace handles it, less seamless |
