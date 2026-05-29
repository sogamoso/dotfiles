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
~/Code/dotfiles/themes/tokyo-night/backgrounds/
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

## 8. Raycast Hotkeys

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

---

## 9. Set Fastmail as Default Email Client

1. Open the **Mail** app (one-time, to expose the default-mail-client setting)
2. From the **Mail** menu, choose **Settings** → **General**
3. Set **Default email reader** to **Fastmail**

---

## 10. Route Sound Effects to the Active Output

By default macOS pins notification/alert sounds to a fixed device, so they leak out of monitor speakers when audio is on AirPods.

System Settings → Sound → set **Play sound effects through** to **Selected sound output device**.

---

## 11. Allow terminal-notifier Notifications

`reminder.sh` (and any future script that uses `terminal-notifier`) needs notification permission. On first invocation macOS pops a permission prompt — accept it. If you missed the prompt:

System Settings → Notifications → **terminal-notifier** → enable **Allow Notifications**.

---

## 12. First Launch of Solo

`install/macos/solo.sh` copies `Solo.app` into `/Applications` but doesn't bypass Gatekeeper or activate the license.

1. First open: right-click `Solo.app` in Finder → **Open** → confirm the Gatekeeper prompt (the app was downloaded from the internet, not signed via the App Store).
2. Sign in / activate license via Solo's onboarding (free beta as of writing; sign-in is required).
3. Subsequent updates happen in-app via **Solo → Check for Updates**.

---

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
| `SUPER + SHIFT + arrows` — move window | Option+Ctrl+arrows (remapped to free Option+Shift for word selection) |
| `SUPER + C/V` — copy/paste | Cmd+C/V already works on macOS |
| Per-monitor independent workspaces | Aerospace handles it, less seamless |
