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

## 9. Set the Default Email Client

Mail and calendar both run as Chrome PWAs (`install/macos/pwas.sh` installs Gmail and
Google Calendar), so there is no native mail client to hand `mailto:` to.

A Chrome-installed PWA does not register as a mail client. It gets a bundle ID of the form
`com.google.Chrome.app.<extension-id>`, claims no URL schemes, and so never appears in
Mail's **Default email reader** picker. Asking LaunchServices which apps claim `mailto:`
returns only Apple Mail and Zoom — not Chrome, and not the Gmail PWA.

Chrome cannot take `mailto:` from its bundle alone either. Its `Info.plist` declares only
`http`, `https`, `file` and `google-chrome` — no `mailto` — so `duti -s com.google.Chrome
mailto` exits 0 but changes nothing, and Chrome does not appear in Mail's picker. Chrome
registers the scheme at *runtime*, via `LSSetDefaultHandlerForURLScheme`, only once you
allow Gmail to handle email links inside the browser.

So the Chrome-side step is not optional and must come first:

1. In Chrome, open <https://mail.google.com>. Click the double-diamond **protocol handler**
   icon at the right of the address bar and allow `mail.google.com` to open email links. If
   the icon is absent, go to **Settings → Privacy and security → Site settings → Additional
   permissions → Protocol handlers** and confirm Gmail is listed. Accept Chrome's prompt to
   become the default mail client if it offers one.
2. Confirm the registration took:

   ```bash
   lsregister -dump | awk '/^[[:space:]]*path:/{p=$2} /claimed schemes:.*mailto/{print p}' | sort -u
   ```

   (`lsregister` lives in
   `/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/`.)
   Chrome should now be listed alongside Apple Mail. Until it is, no amount of `duti` or
   Mail-picker fiddling will bind the scheme.
3. Once Chrome claims `mailto:`, either set **Mail → Settings → General → Default email
   reader** to **Google Chrome**, or run `duti -s com.google.Chrome mailto`. If Mail has no
   account the control stays greyed out — add any account (e.g. **Other Mail Account**) with
   throwaway credentials to unlock it, then remove the account afterward.

Test with `open mailto:test@example.com`. It should land in a Gmail compose view.

Note that `mailto:` opens a Chrome **tab**, not the standalone Gmail PWA window — the
browser and the PWA are separate LaunchServices clients, and only the browser can take the
scheme.

### Calendar

`.ics` invites and `webcal://` links open Calendar.app. The Google Calendar PWA has the same
limitation as Gmail's: no claimed schemes, no document types, so it never appears in
**Calendar.app → Settings → General → Default calendar app**. Import invites from inside
Google Calendar rather than double-clicking the file.

`Option + Shift + E` opens the Gmail PWA and `Option + Shift + C` opens the Google Calendar
PWA. Workspace 4 is where both live.

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
