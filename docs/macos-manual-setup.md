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
~/Code/sogamoso/dotfiles/themes/tokyo-night/backgrounds/
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

Nothing in the Chrome stack can take the scheme. A Chrome-installed PWA gets a bundle ID of
the form `com.google.Chrome.app.<extension-id>` and declares no `CFBundleURLTypes` at all.
Chrome itself declares only `http`, `https`, `file` and `google-chrome` — no `mailto` — so
`duti -s com.google.Chrome mailto` exits 0 and changes nothing. LaunchServices only lets a
bundle claim a scheme it declares, so neither ever appears in Mail's **Default email
reader** picker.

Chrome's **Settings → Privacy and security → Site settings → Protocol handlers** entry for
`mail.google.com` is still worth allowing, but it is browser-internal routing: it decides
what happens to `mailto:` links clicked *inside Chrome*. It never reaches LaunchServices,
and Chrome never shows up in the scheme dump however it is set.

`install/macos/mailto.sh` closes the gap with an AppleScript applet at
`~/Applications/Gmail Mailto.app`. The applet declares `mailto` in its own `Info.plist`, so
it is eligible to be the system handler, and LaunchServices delivers a clicked link as a
GetURL Apple Event — which only `on open location` receives, so a shell script in a bundle
would get nothing. It percent-encodes the URI, opens
`https://mail.google.com/mail/?extsrc=mailto&url=…` through `open -na 'Google Chrome'
--args --app=`, and exits. `LSUIElement` keeps it out of the Dock.

`--app=` gives a chromeless window — no tab strip, no address bar — so compose opens in
something that looks like the Gmail PWA rather than a tab. It is not the installed PWA: the
`Gmail.app` shim is an `app_mode_loader` that ignores a URL argument, so `open -a` activates
that window without navigating it. A fresh app window opens per `mailto:` link.

The URL carries no account selector, so Gmail uses the default account for the Chrome
profile. Do not try to pin it with an address — `/mail/u/<address>/` is not a valid
selector and Gmail answers it with *Temporary Error (404)*. Only a numeric index (`u/0`)
works there, and that follows sign-in order rather than naming a mailbox.

The script builds the app only when it is missing. Delete the bundle and rerun to rebuild.

Confirm the binding took:

```bash
defaults read com.apple.LaunchServices/com.apple.launchservices.secure |
  grep -B2 'LSHandlerURLScheme = mailto'
```

It should report `LSHandlerRoleAll = "so.sogamo.gmail-mailto"`. To list every claimant:

```bash
lsregister -dump |
  awk '/^[[:space:]]*path:/{p=$0; sub(/^[[:space:]]*path:[[:space:]]*/,"",p)
                            sub(/[[:space:]]*\(0x[0-9a-f]+\)$/,"",p)}
       /claimed schemes:.*mailto/{print p}' | sort -u
```

(`lsregister` lives in
`/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/`.)
Extract the path from `$0` rather than `$2`: `$2` truncates `Gmail Mailto.app` at the
space. The second `sub` drops the trailing LaunchServices id.

Test with `open mailto:test@example.com`. It should land in a Gmail compose view. Note that
`duti -x mailto` is not a check: `-x` queries file extensions, not URL schemes, and errors
out even when the scheme is bound correctly.

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

## 13. Sign In to Hermes and Set Its Defaults

`hermes-desktop` installs from the `Brewfile`, but its account and settings are not in
dotfiles. The sign-in is a browser OAuth flow that writes credentials to
`~/.hermes/auth.json` and `~/.hermes/.env` — per-machine secrets that must never be
committed. Run it by hand:

```bash
hermes portal login
```

Confirm with `hermes portal status`: it should report logged in, Nous as the inference
provider, and the Tool Gateway routing web tools, image generation, TTS and browser
automation through Nous.

`~/.hermes/config.yaml` holds the routing settings below. It contains no secrets, but
Hermes rewrites it as the agent runs, so it is recorded here rather than stowed, to avoid a
permanently dirty tracked file. `model.default` is deliberately omitted — it changes
whenever you switch models, so any value written here would go stale.

| Key | Value |
|---|---|
| `model.provider` | `nous` |
| `model.base_url` | `https://inference-api.nousresearch.com/v1` |
| `model.api_mode` | `chat_completions` |
| `web.backend` | `nous` |
| `browser.cloud_provider` | `nous` |
| `agent.max_turns` | `500` |
| `agent.reasoning_effort` | `medium` |

Set them with `hermes config set <key> <value>` or the desktop app's settings. Revisit
stowing the file if Hermes ever grows a non-interactive config import.

To connect the desktop app to a Hermes Cloud instance, use **Settings → Gateways → Add
connection → Hermes Cloud** (Cmd+, then Gateways) and complete the portal sign-in. The
flow discovers instances automatically; there are no URL or token fields to fill.

Note that `install/macos/hermes.sh` deletes any `ai.hermes.gateway` launch agent on every
bootstrap, so Hermes runs only while the desktop app is open. If you later want a gateway
persisting in the background, that script has to change first.

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
