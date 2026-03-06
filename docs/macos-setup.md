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

1. Open Raycast → Settings → General
2. Set **Raycast Hotkey** to `Ctrl+Space`
3. Disable Spotlight: System Settings → Keyboard → Keyboard Shortcuts → Spotlight → uncheck all

---

## 3. Test tmux Prefix

The omadots/Omarchy tmux prefix is `Ctrl+Space` (`C-Space`).

Open Ghostty or Alacritty and press physical **Cmd+Space**, then `c` — a new window should open.

If it doesn't work (Raycast intercepts it), add this to `~/.config/alacritty/alacritty.toml`:

```toml
[keyboard]
bindings = [
  { key = "Space", mods = "Command", chars = "\x00" }
]
```

The fallback prefix is `C-b` (omadots sets `prefix2 = C-b`).

---

## 4. Slack Tokyo Night Theme

Slack → Preferences → Themes → Custom Theme → paste:

```
#1a1b26,#32344a,#7aa2f7,#a9b1d6,#444b6a,#a9b1d6,#9ece6a,#7aa2f7,#1a1b26,#a9b1d6
```

---

## Keybinding Reference

### Window Management (Aerospace)

Physical Cmd = SUPER on Omarchy (Karabiner maps Cmd → Ctrl under the hood).

| Physical keys | Action | Omarchy equivalent |
|---|---|---|
| Cmd + 1–9 | Switch workspace | SUPER + 1–9 |
| Cmd + 0 | Workspace 10 (scratchpad) | SUPER + 0 |
| Cmd + Shift + 1–9 | Move window to workspace | SUPER + SHIFT + 1–9 |
| Cmd + arrows | Focus window | SUPER + arrows |
| Cmd + Shift + arrows | Move window | SUPER + SHIFT + arrows |
| Cmd + W | Close window | SUPER + W |
| Cmd + F | Fullscreen | SUPER + F |
| Cmd + T | Toggle floating | SUPER + T |
| Cmd + J | Toggle split direction | SUPER + J |
| Cmd + L | Toggle layout | SUPER + L |
| Cmd + Tab | Next workspace | SUPER + TAB |
| Cmd + -/= | Resize width | SUPER + -/= |
| Cmd + Space | Raycast launcher | SUPER + SPACE |
| Cmd + Enter | New Ghostty window | SUPER + RETURN |
| Cmd + Shift + Enter | New Chrome window | SUPER + SHIFT + RETURN |
| Cmd + Shift + N | New Zed window | SUPER + SHIFT + N |
| Alt + Tab | Cycle windows (AltTab) | ALT + TAB |

### tmux (Prefix = Ctrl+Space, same as Omarchy)

| Keys | Action | Prefix? |
|---|---|---|
| `prefix + h/v` | Split horizontal/vertical | Yes |
| `prefix + x/k` | Kill pane/window | Yes |
| `Ctrl+Alt+Arrow` | Navigate panes | No |
| `Alt+1–9` | Switch window | No |
| `Alt+Left/Right` | Prev/next window | No |
| `prefix + c` | New window | Yes |
| `prefix + r/R` | Rename window/session | Yes |
| `prefix + [` | Copy mode (`v` select, `y` copy) | Yes |

### System (after Karabiner swap)

Physical Ctrl → sends Cmd to macOS.

| Physical keys | macOS action |
|---|---|
| Ctrl + C/V/Z/S | Copy / Paste / Undo / Save |
| Ctrl + Q | Quit app |
| Cmd + W | Close Aerospace window (not macOS Cmd+W) |

---

## Workspace Layout

| Workspace | App |
|---|---|
| 1 | Chrome |
| 2 | Ghostty |
| 3 | Slack |
| 4 | Gmail |
| 5 | Google Calendar |
| 6 | Notion |
| 7 | Spotify |
| 8 | YouTube |
| 9 | (free) |
| 10 | Scratchpad (Cmd+0) |

---

## Remaining Gaps vs Omarchy

| Omarchy | macOS |
|---|---|
| `SUPER + O` — float & pin | Float only via Cmd+T, no pin-on-top |
| `SUPER + SHIFT + SPACE` — toggle waybar | No SketchyBar hotkey toggle |
| `SUPER + mouse drag` — move/resize | Keyboard resize only |
| Per-monitor independent workspaces | Aerospace handles it, less seamless |
