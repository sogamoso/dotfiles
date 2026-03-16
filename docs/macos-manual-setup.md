# macOS → Manual Setup

The installer (`bootstrap`) handled everything that can be automated. Everything in this doc requires human intervention. The goal is to finalize the setup to make macOS feel like closer to Omarchy to make the transition between the two systems smoother.

---

## 1. Grant Accessibility Permissions

macOS requires manual approval for any app that controls input or windows.
Open each prompt as it appears during the install, or go here:

**System Settings → Privacy & Security → Accessibility**
- Aerospace

---

## 2. Set Raycast Hotkey

System Settings → Keyboard → Keyboard Shortcuts — disable all shortcuts in these sections:

1. **Mission Control** — conflicts with AeroSpace workspace bindings. After disabling, re-enable and rebind:
   - **Show Notification Center** → `Option + ,`
   - **Turn Do Not Disturb On/Off** → `Option + Ctrl + ,`
2. **Windows** — conflicts with AeroSpace window bindings
3. **Input Sources** — Globe/Fn key handles language switching instead
4. **Spotlight** — Raycast takes that slot

Then set Raycast as the launcher:

5. Open Raycast → Settings → General
6. Set **Raycast Hotkey** to `Option+Space`

---

## 3. Login Items

System Settings → General → Login Items — add:

- AeroSpace
- cctop
- CleanShot X
- Dropbox
- Freedom
- Gmail
- Google Calendar
- Google Drive
- Monologue
- Raycast

---

## 4. Authenticate GitHub CLI

Open a terminal and run:

```
gh auth login
```

---

## 5. Applying a Theme

### Wallpaper

Browse the available wallpapers and choose one.Then in System Settings → Wallpaper → Add Folder → select:

```
~/Code/dotfiles/themes/tokyo-night/backgrounds/color/
```

For the screen saver, check:

```
~/Code/dotfiles/themes/tokyo-night/backgrounds/grayscale/
```

Copy your pick into the `active` folder:

```
cp ~/Code/dotfiles/themes/tokyo-night/backgrounds/grayscale/<wallpaper> \
   ~/Code/dotfiles/themes/tokyo-night/backgrounds/grayscale/active/
```

Then in System Settings → Wallpaper → Screen Saver → select the grayscale wallpaper you just copied.

### Slack

Slack → Preferences → Themes → Custom Theme → paste:

```
#1a1b26,#32344a,#7aa2f7,#a9b1d6,#444b6a,#a9b1d6,#9ece6a,#7aa2f7,#1a1b26,#a9b1d6
```

---

## 6. Monologue Dictation Hotkey

Open Monologue → Settings → set the global hotkey to `Option+Ctrl+X` (SUPER+Ctrl+X on Omarchy).

---

## Raycast Hotkeys

Set these hotkeys in Raycast → Extensions:

- **Script Commands → Apple Menu** → `Option + Escape` (Omarchy: SUPER + Escape)
- **Script Commands → Hotkeys Cheatsheet** → `Option + K` (Omarchy: SUPER + K)
- **Emoji & Symbols** → `Option + Ctrl + E` (Omarchy: SUPER + Ctrl + E)

## Hotkeys Reference

| Physical key | macOS sends | Role | Omarchy equivalent |
|---|---|---|---|
| Option | Alt/Option | Window management | Super |
| Command | Cmd | App shortcuts + tmux | Alt |


## Remaining Gaps vs Omarchy

| Omarchy | macOS |
|---|---|
| `SUPER + O` — float & pin | Float only via Option+T, no pin-on-top |
| `SUPER + G` — window grouping | No AeroSpace equivalent |
| `SUPER + SHIFT + SPACE` — toggle waybar | No SketchyBar hotkey toggle |
| `CapsLock` — quick emojis | Needs remapping tool |
| `SUPER + Ctrl + A/B/W` — audio/bluetooth/wifi TUIs | ✅ Option+Ctrl+A/B/W → System Settings |
| `SUPER + Ctrl + Z` — screen zoom | Use macOS Accessibility zoom |
| `SUPER + Ctrl + X` — dictation | ✅ Option+Ctrl+X → Monologue |
| `SUPER + C/V` — copy/paste | Cmd+C/V already works on macOS |
| Per-monitor independent workspaces | Aerospace handles it, less seamless |
