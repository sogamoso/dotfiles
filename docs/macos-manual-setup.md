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
- Epistles
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

**Script Commands → Secure Input** deliberately gets no hotkey. It reports which app is holding macOS Secure Input, and Secure Input blocks the event tap AeroSpace reads keys through — a binding would be dead exactly when you need it. Invoke it by name from the Raycast launcher, or run `~/.config/dotfiles/secure-input.sh` in a terminal.

### CleanShot

Set in CleanShot → Settings → Shortcuts:

- **Capture Text (OCR)** → `Cmd + Shift + 6` (Omarchy: SUPER + Ctrl + PrtSc — the PrtSc key sends `3` with modifiers on Lofree keyboards, so this combo replaces the AeroSpace `f13` binding)

---

## 9. Set Epistles as the Default Email and Calendar

Epistles is a native app, so unlike the Gmail and Google Calendar PWAs it replaces, it can hold the system handlers itself — no Chrome protocol-handler detour, and no `.ics` import dance. It installs from the repo-local tap (`cask "sogamoso/dotfiles/epistles"` in the `Brewfile`), so it is already present by the time you reach this step.

### Default email

Epistles registers the `mailto:` scheme and claims `com.apple.default-app.mail-client`, so it appears by name in Mail's picker.

1. Open the **Mail** app. If it has no account the default-reader control stays greyed out — add any account (e.g. **Other Mail Account**) with throwaway credentials to unlock the setting, then remove it afterward.
2. **Mail → Settings → General**, set **Default email reader** to **Epistles**. Quit Mail.
3. Test: `open mailto:test@example.com` should open a compose window in Epistles.

### Default calendar

**Calendar.app → Settings → General → Default calendar app → Epistles**. macOS assigns `webcal://`, `.ics` and `.vcs` in one move, so invite files and subscription links both follow.

### Scripted alternative

Both pickers just write LaunchServices handler entries, which `duti` (already in the `Brewfile`) can set directly:

```bash
duti -s com.epistles com.apple.default-app.mail-client all
duti -s com.epistles mailto
duti -s com.epistles com.apple.ical.ics all
duti -s com.epistles com.apple.ical.vcs all
duti -s com.epistles webcal
```

Verify with `duti -x ics`, which should print `Epistles`.

Epistles declares no `CFBundleDocumentTypes` in its `Info.plist` — it takes the calendar handlers at runtime rather than advertising them. macOS will therefore hand it an `.ics`, but the app never declared that it opens one. Open a real invite once and confirm the behavior before trusting it for meeting invites.

Epistles replaces the Gmail and Google Calendar PWAs and the Fastmail cask outright — none of the three are installed any more. Workspace 4 is now Epistles alone, and `Option + Shift + E` and `Option + Shift + C` both open it.

---

## 10. Route Sound Effects to the Active Output

By default macOS pins notification/alert sounds to a fixed device, so they leak out of monitor speakers when audio is on AirPods.

System Settings → Sound → set **Play sound effects through** to **Selected sound output device**.

---

## 11. Allow terminal-notifier Notifications

`reminder.sh` (and any future script that uses `terminal-notifier`) needs notification permission. On first invocation macOS pops a permission prompt — accept it. If you missed the prompt:

System Settings → Notifications → **terminal-notifier** → enable **Allow Notifications**.

---

## 12. Store the ui.sh Token

The `ui`, `brand-kit` and `markup-from-image` skills are stowed as stubs that fetch their instructions from ui.sh over MCP, so they do nothing until `uidotsh.sh` can find an account token. The token can't be generated non-interactively — copy it from an existing machine's `~/.claude.json` (`mcpServers.uidotsh.headers.Authorization`) or from the ui.sh account page, then store it in 1Password as a password item titled **ui.sh**:

```
op item create --category=password --title='ui.sh' password=-
```

Rerun `bash install/dotfiles/uidotsh.sh` afterwards, then confirm with `claude mcp get uidotsh`. To keep the item somewhere else, point `UIDOTSH_OP_ITEM` at it; to skip 1Password entirely, set `UIDOTSH_TOKEN` in the environment.

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
| `SUPER + ALT + SHIFT + F` — file manager at terminal cwd | Not mapped; `open .` in the shell does the same. A port needs `aerospace list-windows --focused --format '%{app-pid}'` plus `lsof -d cwd` (no `/proc` on macOS), and the parent-child descent misses the shell entirely under tmux or herdr |
| `SUPER + SHIFT + G` — Signal | Not mapped; Signal is not installed. Option+Shift+G opens WhatsApp, which upstream puts on `SUPER + SHIFT + ALT + G` |
| `SUPER + SHIFT + CTRL + G` — Google Messages | Not mapped; no PWA installed |
| `SUPER + SHIFT + P` — Google Photos | Not mapped; no PWA installed |
| `SUPER + SHIFT + ALT + M` — cliamp music TUI | No macOS equivalent; Spotify is on Option+Shift+M |
| `SUPER + SHIFT + ALT + A` — Grok | Option+Shift+Cmd+A opens ChatGPT instead |
