# macOS → Manual Setup

The installer (`bootstrap`) handled everything that can be automated. Everything in this doc requires human intervention. The goal is to finalize the setup to make macOS feel like closer to Omarchy to make the transition between the two systems smoother.

---

## 1. Grant Accessibility Permissions

macOS requires manual approval for any app that controls input or windows.
Open each prompt as it appears during the install, or go here:

**System Settings → Privacy & Security → Accessibility**
- Aerospace

---

## 2. Disable Keyboard Shortcuts

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
- CleanShot X
- Dropbox
- Fastmail
- Freedom
- Gmail
- Google Calendar
- Google Drive
- Monologue
- Raycast
- Slack

---

## 4. Menu Bar

System Settings → Control Center → Menu Bar Only — enable only:

- Wi-Fi
- Bluetooth
- Text Input

Disable everything else (Siri, Spotlight, Battery, AirDrop, Focus, Screen Mirroring, Display, Sound, Now Playing, Fast User Switching, Time Machine, Keyboard Brightness, Timer, Weather).

---

## 5. Authenticate GitHub CLI

Open a terminal and run:

```
gh auth login
```

---

## 6. Applying a Theme

### Wallpaper

Browse the available wallpapers and choose one. Then in System Settings → Wallpaper → Add Folder → select:

```
~/Code/personal/dotfiles/themes/tokyo-night/backgrounds/
```

### Screen Saver

1. Visit https://fliqlo.com/screensaver/
2. Download and install Fliqlo
3. System Settings → Screen Saver → select **Fliqlo**
4. System Settings → Wallpaper → Clock Appearance → set **Show large clock** to **Never** (prevents the system clock from overlapping with Fliqlo)

### Slack

Slack → Preferences → Themes → Custom Theme → paste:

```
#1a1b26,#32344a,#7aa2f7,#a9b1d6,#444b6a,#a9b1d6,#9ece6a,#7aa2f7,#1a1b26,#a9b1d6
```

---

## 7. Monologue Dictation Hotkey

Open Monologue → Settings → set the global hotkey to `Option+Ctrl+X` (SUPER+Ctrl+X on Omarchy).

---

## 8. Manually-Assigned Hotkeys

Hotkeys assigned inside specific apps (per-machine, not in dotfiles).

### Raycast

Set these hotkeys in Raycast → Extensions (only needed before enabling Cloud Sync — hotkeys sync across machines after that):

- **Script Commands → Apple Menu** → `Option + Escape` (Omarchy: SUPER + Escape)
- **Script Commands → Hotkeys Cheatsheet** → `Option + K` (Omarchy: SUPER + K)
- **Script Commands → Zed Cheatsheet** → `Option + Shift + K`
- **Script Commands → Set Reminder** → `Option + Ctrl + R` (Omarchy: SUPER + Ctrl + R)
- **Script Commands → Show Reminders** → `Option + Ctrl + Cmd + R` (Omarchy: SUPER + Ctrl + Alt + R)
- **Script Commands → Clear Reminders** → `Option + Ctrl + Shift + R` (Omarchy: SUPER + Shift + Ctrl + R)
- **Search Emoji & Symbols** → `Option + Ctrl + E` (Omarchy: SUPER + Ctrl + E)
- **Clipboard History** → `Option + Ctrl + V` (Omarchy: SUPER + Ctrl + V)
- **Lock Screen** → `Option + Ctrl + L` (Omarchy: SUPER + Ctrl + L)
- **Sound** → `Option + Ctrl + A` (Omarchy: SUPER + Ctrl + A)
- **Bluetooth** → `Option + Ctrl + B` (Omarchy: SUPER + Ctrl + B)
- **Wi-Fi** → `Option + Ctrl + W` (Omarchy: SUPER + Ctrl + W)

### CleanShot

Set in CleanShot → Settings → Shortcuts:

- **Capture Text (OCR)** → `Cmd + Shift + 6` (Omarchy: SUPER + Ctrl + PrtSc — the PrtSc key sends `3` with modifiers on Lofree keyboards, so this combo replaces the AeroSpace `f13` binding)

---

## 9. Set Gmail and Google Calendar as Defaults

### Default email (Gmail)

There is no System Settings panel for the default email app — the control lives inside Mail, and it stays greyed out until Mail has at least one account. Since mail routes through Gmail/Fastmail in the browser, Apple Mail may have no account; add a throwaway one to unlock the setting if needed.

The system-level `mailto:` handler is **Google Chrome the browser**, not the Gmail PWA — a Chrome-installed PWA doesn't register as a mail client and won't appear by name. Chrome then hands `mailto:` to Gmail's web handler.

1. Confirm Google Chrome is installed at `/Applications/Google Chrome.app`.
2. Open the **Mail** app. If it has no account, the default-reader control is greyed out — add any account (e.g. **Other Mail Account**) with throwaway credentials so the setting unlocks; remove it afterward.
3. **Mail → Settings → General**, set **Default email reader** to **Google Chrome** (if it isn't listed, choose **Select…** and pick `/Applications/Google Chrome.app`). Quit Mail and remove the throwaway account if you added one.
4. In Chrome, open https://mail.google.com and click the protocol-handler (double-diamond) icon at the right of the address bar → allow Gmail to open email links. If the icon is missing, open `chrome://settings/handlers`, ensure "Sites can ask to handle protocols" is on, remove any blocked `mail.google.com` entry, reload Gmail, and retry.
5. Test: `open mailto:test@example.com` in a terminal should land in a Gmail compose tab.

`mailto:` clicks open in a Chrome tab, not the standalone Gmail PWA window — the two are separate.

### Default calendar (Google Calendar)

macOS cannot make a Chrome PWA the default calendar app. Only `Calendar.app` registers the `webcal://` and `.ics` handlers (verified via `lsregister` — Chrome claims neither), and the picker at **Calendar.app → Settings → General → Default calendar app** lists only native apps that register those handlers, so Chrome and the PWA never appear. Best achievable compromise:

- **`.ics` invite files:** in Finder, select an `.ics`, press **Cmd+I (Get Info) → Open with → Other… → All Applications → Google Chrome.app → Change All**. Target full Chrome.app, not the PWA — the PWA declares no document types and its bundle id changes on reinstall. Opening an `.ics` in Chrome only downloads it; add it via **Google Calendar → Settings → Import & export → Import**.
- **`webcal://` subscription links:** no OS-level path to a PWA. Copy the link, change `webcal://` to `https://`, and subscribe via **Google Calendar → Other calendars (+) → From URL**. Usually works, not guaranteed for every publisher.
- Calendar links clicked in other apps (Mail, Slack) still open `Calendar.app`, which is SIP-protected and can't be removed.

---

## 10. Route Sound Effects to the Active Output

By default macOS pins notification/alert sounds to a fixed device, so they leak out of monitor speakers when audio is on AirPods.

System Settings → Sound → set **Play sound effects through** to **Selected sound output device**.

---

## 11. Allow terminal-notifier Notifications

`reminder.sh` (and any future script that uses `terminal-notifier`) needs notification permission. On first invocation macOS pops a permission prompt — accept it. If you missed the prompt:

System Settings → Notifications → **terminal-notifier** → enable **Allow Notifications**.

---

## Remaining Gaps vs Omarchy

Omarchy's desktop shell runs on [Quickshell](https://quickshell.org) and Hyprland, so a large part of it has no macOS analogue and is out of scope here: the shell process itself, the Hyprland configs, the ISO installer, pacman packaging, and the PAM fingerprint flows. Another tier is already native — Raycast covers the launcher, clipboard manager and emoji picker, and macOS provides Notification Center, Control Center and Touch ID.

What is left worth tracking:

| Omarchy | macOS |
|---|---|
| `SUPER + O` — float & pin | Float only via Option+T, no pin-on-top |
| `SUPER + G` — window grouping | No AeroSpace equivalent |
| `SUPER + SHIFT + arrows` — move window | Option+Ctrl+arrows (remapped to free Option+Shift for word selection) |
| Window position save/restore per workspace | No AeroSpace equivalent |
| Per-monitor independent workspaces | Aerospace handles it, less seamless |
| Bar transparency and repositioning by double-click and drag | No SketchyBar equivalent; height and position are set in `sketchybarrc` |
| Model-usage bar widget | ✅ Claude usage item, via `ccusage` |
| Microphone state indicator | ✅ Mic item, visible while muted |
| Stay-awake indicator | ✅ Stay awake item, tracks caffeinate |
| Herdr layouts (`hdl`/`hds`/`hdlm`/`hsl`) | ✅ Ported to zsh in `stow/zsh/.config/zsh/aliases/herdr.zsh` |
| SSH reconnect and terminal cleanup on drop | ✅ Keepalives surface a dead link in ~45s; no terminal-state reset |
| Themes generating nvim/btop/VS Code colors from one colorset | `themes/tokyo-night/colors.toml` exists but nothing consumes it |
| Visual theme and background switchers | No equivalent |
| `SUPER + Ctrl + A/B/W` — audio/bluetooth/wifi TUIs | ✅ Option+Ctrl+A/B/W → System Settings |
| `SUPER + Ctrl + D` / `P` — display and power panels | Only A/B/W are mapped |
| `SUPER + Ctrl + X` — dictation | ✅ Option+Ctrl+X → Monologue |
| `SUPER + Ctrl + Z` — screen zoom | Use macOS Accessibility zoom |
| `CapsLock` — quick emojis | Needs remapping tool |
| `SUPER + C/V` — copy/paste | Cmd+C/V already works on macOS |
