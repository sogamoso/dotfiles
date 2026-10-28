# macOS → Manual Setup

The installer (`bootstrap`) handled everything that can be automated. Everything in this doc requires human intervention. The goal is to finalize the setup to make macOS feel like closer to Omarchy to make the transition between the two systems smoother.

---

## 1. Grant Accessibility Permissions

macOS requires manual approval for any app that controls input or windows.
Open each prompt as it appears during the install, or go here:

**System Settings → Privacy & Security → Accessibility**
- Aerospace
- MacWhisper (types dictation into the focused field)
- Vicinae (pastes and expands snippets)

**System Settings → Privacy & Security → Microphone**
- MacWhisper

**System Settings → Privacy & Security → Local Network**
- LocalSend — allow it at the first-launch prompt, or it can't see other devices. The firewall also asks once whether to accept incoming connections; allow that too, or nothing can send to this Mac.

**System Settings → Privacy & Security → Automation** — whichever terminal you run the installer from needs **System Events** enabled under it. Without it, the two `osascript` calls in `install/macos/preferences.sh` fail with `-1743 Not authorized to send Apple events`, and dark mode and the auto-hidden menu bar are silently skipped. The script warns and carries on rather than stopping, so a missed grant costs those two settings and nothing else.

---

## 2. Disable Keyboard Shortcuts

Nothing to do. `install/macos/preferences.sh` sets **System Settings → Keyboard →
Keyboard Shortcuts** from `install/lib/symbolic-hotkeys.sh`, and `dotfiles doctor`
flags any that change. These sections are turned off:

1. **Mission Control** — conflicts with AeroSpace workspace bindings. Two stay on, rebound:
   - **Show Notification Center** → `Option + ,`
   - **Turn Do Not Disturb On/Off** → `Option + Ctrl + ,`
2. **Windows** — conflicts with AeroSpace window bindings
3. **Input Sources** — `Option + I` switches language instead (Fn does nothing), and `Ctrl + Space` stays free for the tmux and herdr prefix
4. **Spotlight** — Vicinae takes that slot
5. **Screenshots** — CleanShot takes `Cmd + Shift + 3/4/5` (see step 7)

To change one, edit it in System Settings, then update its line in
`symbolic-hotkeys.sh` to match (`defaults export com.apple.symbolichotkeys -`
shows the values), or the next bootstrap puts it back.

---

## 3. Login Items

Nothing to do. `install/macos/login-items.sh` adds the apps listed in
`install/lib/login-items.sh` and leaves any others alone, and `dotfiles doctor`
names any that stop opening at login. It goes through System Events, so it
needs the Automation grant in section 1.

---

## 4. Menu Bar

`install/macos/preferences.sh` sets **System Settings → Menu Bar → Menu Bar Controls**: only Wi-Fi, Bluetooth and Text Input show, and Clock always does. Nothing to do here unless one comes back.

Then trim third-party items by hand. macOS keeps this list in an encoded record Control Center owns, so bootstrap leaves it alone. System Settings → Menu Bar → Allow in the Menu Bar — keep only:

- 1Password
- AeroSpace
- CleanShot X
- Codex Computer Use
- Dropbox
- Freedom
- Google Drive
- LocalSend
- ScriptMonitor
- SSMenuAgent
- Tuple
- Vicinae
- Wabi

Turn off every other app (Basecamp, Claude, Codex, Gemini, Granola, MacWhisper, Notion, Zoom, …). Turning one off stops its icon from ever appearing; the app itself keeps working. Vicinae shows no icon even while allowed, since `tray.enabled` is off in its stowed config.

### Opaque menu bar

The menu bar is set to auto-hide, so SketchyBar owns the top strip and the system bar only slides down on hover. macOS draws that reveal as translucent glass, which lets SketchyBar show through and puts two overlapping sets of items on screen.

`install/macos/preferences.sh` turns off transparency to prevent this, but WindowServer only reads the setting at login — it is not enough to write it. If the revealed menu bar looks transparent, log out and back in, or toggle **System Settings → Accessibility → Display → Reduce transparency** off and on.

---

## 5. Authenticate GitHub CLI

Open a terminal and run:

```
gh auth login
```

`dotfiles doctor` reports it if the CLI is ever signed out.

---

## 6. Applying a Theme

### Wallpaper

Browse the available wallpapers and choose one. Then in System Settings → Wallpaper → Add Folder → select:

```
~/Work/sogamoso/dotfiles/themes/tokyo-night/backgrounds/
```

### Screen Saver

The `fliqlo` cask in the Brewfile installs it. Then:

1. System Settings → Wallpaper → Screen Saver → select **Fliqlo**
2. System Settings → Wallpaper → Clock Appearance → set **Show large clock** to **Never** (prevents the system clock from overlapping with Fliqlo)

### Slack

Slack → Preferences → Themes → Custom Theme → paste:

```
#1a1b26,#32344a,#7aa2f7,#a9b1d6,#444b6a,#a9b1d6,#9ece6a,#7aa2f7,#1a1b26,#a9b1d6
```

---

## 7. Manually-Assigned Hotkeys

Hotkeys assigned inside specific apps (per-machine, not in dotfiles).

### Vicinae

Nothing to assign. The launcher hotkey (`Option + Space`) is set in the stowed `~/.config/vicinae/dotfiles.json`, and every other launcher command is an AeroSpace binding to a Vicinae deeplink, listed in the README.

Nothing to install by hand either: bootstrap installs the store extensions listed in `stow/macos/.config/vicinae/extensions.txt`. Change settings or extensions in Vicinae as usual, then run `dotfiles vicinae save` and commit to keep the change, or `dotfiles vicinae reset` to drop it. `dotfiles doctor` flags anything not yet saved. Extension passwords and tokens are kept in Vicinae's own database, never in the repo, so each extension still asks for them once per Mac. Linear signs in over OAuth on first use.

**1Password** doesn't fully work under Vicinae: it opens `raycast://` once it has signed in through the 1Password CLI, to bring Raycast back to the front. Vicinae only registers `vicinae://` on macOS, so with Raycast uninstalled that last step has nowhere to go. Raycast extensions whose only command is a menu bar item never appear at all, since Vicinae has no menu bar commands, so leave those out of `extensions.txt`.

**Secure Input** deliberately gets no hotkey. It reports which app is holding macOS Secure Input, and Secure Input blocks the event tap AeroSpace reads keys through — a binding would be dead exactly when you need it. Open the launcher (still works: Vicinae registers `Option + Space` itself) and run it by name, or run `~/.config/dotfiles/secure-input.sh` in a terminal.

### 1Password

1Password → Settings → General → **Show Quick Access** shortcut → `Option + Shift + /` (Omarchy: SUPER + SHIFT + / → 1Password). It's 1Password's own shortcut rather than an AeroSpace binding, so it still works while Secure Input has AeroSpace's bindings dead — which is when a password field is focused. The full app opens from the menu bar icon (section 11).

### MacWhisper

Dictation, replacing Raycast's: hold Right `⌘` to talk (Omarchy: hold Right Alt, which is Command here). `install/macos/preferences.sh` sets the key and the hold-to-talk mode, so they need no hand setup. To tap to start and again to finish instead, switch **Settings → Dictation** to toggle, and change `dictationActivationMode` to `toggle` in `preferences.sh` so bootstrap keeps it.

Set these once per Mac in **Settings → Dictation**, since they live alongside downloaded models:

- **Model** → Parakeet v3, which runs locally, so dictation works offline
- **Language** → Auto Detect, for switching between English and Spanish

Before the key does anything, run MacWhisper's dictation setup once: open MacWhisper → **Dictation**, follow the setup, and grant **Microphone** and **Accessibility** when it asks (the grants in section 1). Until then Right `⌘` silently does nothing, even with the key already set. Check the setup shows Right `⌘` and push to talk, then hold the key in any text field to test.

Dictation belongs to the direct-download build that the `macwhisper` cask installs, not the App Store version.

### CleanShot

The capture chords are AeroSpace bindings now, driven through CleanShot's URL
scheme, so they ship with the repo. What is left here is clearing CleanShot's
own copies, which are stored per-machine and would otherwise fire alongside
them. In CleanShot → Settings → Shortcuts, leave these **unassigned**:

- **General → All-In-One** (AeroSpace holds `Cmd + Shift + 5`)
- **Screenshots → Capture Area** (AeroSpace holds `Cmd + Shift + 4`)
- **Screenshots → Capture Fullscreen** (AeroSpace holds `Cmd + Shift + 3`)
- **Screenshots → Capture Previous Area** — unassigned either way
- **OCR → Capture Text** (AeroSpace holds `Cmd + Shift + 6`)

These chords take over the macOS screenshot keys, so disable the **Screenshots**
section in System Settings first (see step 2).

Then in CleanShot → Settings:

- **General → Export → Export location** → `Downloads`
- **General → After Capture** — for both Screenshot and Recording, enable **Show Quick Access Overlay** and **Copy file to clipboard**. Leave **Save**, **Upload to Cloud & copy link**, **Open Annotate tool**, **Pin to the screen** and **Open Video Editor** off. Set **Copy to clipboard** to **File**.

  With **Save** off nothing is written to the export location automatically. A capture lives in the clipboard and in CleanShot's own media folder, and reaches `Downloads` only when you save it from the Quick Access overlay. That keeps the folder clean at the cost of losing any capture you dismiss without saving.
- **Quick Access → Behavior** → enable **Auto-close**, **Action** → **Close**, **Interval** → **2 minutes**

### LanguageTool

Nothing to assign. Its Correction and Paraphrasing shortcuts default to
`Ctrl + Option + C` and `Ctrl + Option + P`, both AeroSpace bindings, and
whichever app registers a chord first holds it, so the other one goes dead.
`install/macos/preferences.sh` clears both, and `dotfiles doctor` flags it if
an update brings either one back. Its built-in updater can't be turned off (it
switches itself back on at launch); brew autoupdate and it just race to the same
version.

If one did come back, the AeroSpace binding stays dead until AeroSpace
registers it again, so run `aerospace reload-config` after clearing it. By
hand, they're under **Settings… → Shortcuts**, opened from LanguageTool's menu
bar icon.

---

## 8. Set the Default Email Client

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

## 9. Route Sound Effects to the Active Output

By default macOS pins notification/alert sounds to a fixed device, so they leak out of monitor speakers when audio is on AirPods.

System Settings → Sound → set **Play sound effects through** to **Selected sound output device**.

---

## 10. Allow terminal-notifier Notifications

`reminder.sh` (and any future script that uses `terminal-notifier`) needs notification permission. On first invocation macOS pops a permission prompt — accept it. If you missed the prompt:

System Settings → Notifications → **terminal-notifier** → enable **Allow Notifications**.

---

## 11. Enable the 1Password CLI and SSH Agent

1Password → Settings → Developer, the same on every Mac:

1. **1Password Developer** → enable **Show 1Password Developer experience** and **Record and display activity**
2. **SSH Agent** → enable **Use the SSH Agent** (or click **Set up the SSH Agent** on a fresh install). If it offers to edit `~/.ssh/config`, skip that — the stowed config already points `IdentityAgent` at 1Password's socket and includes its bookmarks file. Then under **Advanced**:
   - **Ask approval for each new** → application
   - **Remember key approval** → until 1Password quits
   - **Display key names when authorizing connections** → on. Only item titles are stored unencrypted, and seeing which key a prompt is for (e.g. the signing key during a plain `git fetch`) is what makes an unexpected request stand out.
   - **Generate SSH config file with bookmarked hosts** → on. 1Password writes `~/.ssh/1Password/config`, which the stowed `~/.ssh/config` includes.
   - **Open SSH URLs with** → Ghostty
3. **Developer Integrations** → enable **Integrate with 1Password CLI** and **Integrate with MCP clients**. Leave **Integrate with 1Password SDKs** and **Provision OpenShell providers** off.
4. **Watchtower** → enable **SSH keys** and **.env files**

The SSH agent serves the keys behind `git` over SSH and commit signing (`~/.ssh/id_ed25519_git_signing.pub`). The CLI integration is what lets bootstrap read the ui.sh token; if it was off during bootstrap, rerun `bash install/dotfiles/uidotsh.sh`.

1Password → Settings → General → enable **Keep 1Password in the menu bar** (1Password needs it for Touch ID, Quick Access and the SSH agent too), and set **Click the icon to** → **Show the main window**. With it off, closing the main window (the red button, or Option + W) quits 1Password outright, and the next launch asks for the password again. With it on, closing only hides the window and 1Password keeps running: the menu bar icon brings the window back, and Option + Shift + / opens Quick Access (section 7).

1Password → Settings → Security → **Auto-lock** depends on the Mac:

- **Laptops**: enable **Lock when device locks or sleeps**, and set **Lock after the device is idle for** → 30 minutes. Option + Ctrl + L then locks 1Password along with the screen, as Omarchy's Super + Ctrl + L locks everything, and the idle lock covers a laptop left unlocked somewhere else.
- **Desktops that stay on, like the Mac mini**: leave **Lock when device locks or sleeps** off and the idle lock at **Never**. The machine stays home and is reached over Screen Sharing and SSH, where re-entering the 1Password password after every screen lock costs more than it protects. Option + Ctrl + L locks the screen only.

---

## 12. Install Supernote Partner

The companion app for the Supernote e-ink tablet. Install it from the [App Store listing](https://apps.apple.com/us/app/supernote-partner/id1494992020) (`id1494992020`).

It is absent from `Brewfile` and cannot go there. Ratta ships the macOS build through the App Store only — Windows gets a direct installer from their own servers, macOS does not — so there is no file for a cask to fetch. This is not a missing cask someone could contribute; the artifact does not exist outside Apple's distribution.

`install/macos/apps.sh` does not install it either. `sudo mas get 1494992020` (mas 7.0.0) fails with `ISErrorDomain Code=4 "Unknown Error."` even with the App Store signed in, and `mas signin` no longer works on current macOS. The first install has to be manual, so the Brewfile stays free of App Store entries.

---

## 13. Wabi (installed by bootstrap)

`install/macos/apps.sh` installs Wabi, the group AI assistant, from the Apple silicon DMG at [wabi.ai/download](https://wabi.ai/download). It refuses any build not notarized and signed by Wabi, Inc. (team `J4Q32LA8N4`). If Wabi ever changes signing identity, the script warns and skips the install; check the new identity before updating `WABI_TEAM`.

Homebrew has no `wabi` cask. Since a downloadable build exists, one could be contributed upstream; once it lands in `homebrew/cask`, move Wabi into the Brewfile and drop it from `apps.sh`.

---

## 14. Enable Screen Sharing (always-available machines only)

**Desktop computers that stay on, like the Mac mini — not laptops.** A laptop
moves between networks, and Screen Sharing listens on every one of them.

System Settings → General → Sharing → enable **Screen Sharing**, then under its
ⓘ set **Allow access for** to **Only these users** with just your account. macOS
won't let a script turn it on, which is why it's here.

Connect through Tailscale, using the machine's Tailscale name:

- From another Mac: Finder → Go → Connect to Server → `vnc://<tailscale-name>`
  (e.g. `vnc://sogamoso-m4-mac-mini`), and sign in with that Mac's user account.
- From a phone: the Tailscale app connected, plus a VNC client pointed at the
  same name.

Unlike SSH, Screen Sharing isn't limited to the tailnet: it also answers on the
local network. That's acceptable for a desktop behind a home router; it's the
reason laptops skip this step. Remote Login (macOS's own SSH server) stays off on
every Mac; SSH goes through Tailscale SSH instead.

---

## 15. Reach the Macs from the iPhone (Blink)

Both Macs take SSH and mosh through Tailscale SSH: no keys, and nothing listens
on the local network. The Mac side is automated (`tailscale.sh`, `firewall.sh`,
and the `mac-mini`/`macbook` hosts in `~/.ssh/config`); the phone side lives in
Blink and has to be set up by hand:

1. Install Tailscale on the phone and sign in with `sebastian@sogamo.so`, the
   same account as the Macs. The SSH rule only lets an account into its own
   devices.
2. In Blink → Settings → Hosts, add one host per Mac, matching the Mac-side names:

   | Host | HostName | User |
   | --- | --- | --- |
   | `mac-mini` | `sogamoso-m4-mac-mini` | `sogamoso` |
   | `macbook` | `sogamoso-m5-pro-macbook` | `sogamoso` |

   No key or password: Tailscale authenticates. In **Mosh → Command** put
   `/bin/zsh -lc 'exec herdr'` so `mosh mac-mini` lands in herdr. If Blink asks
   for the server path, it's `/opt/homebrew/bin/mosh-server`.
3. To land in herdr over plain SSH too, add to the host's **SSH Config**:

       RequestTTY yes
       RemoteCommand /bin/zsh -lc 'exec herdr'

The SSH rule in the tailnet policy is `accept`, not `check`: `autogroup:member`
into `autogroup:self` as `autogroup:nonroot`, so an account reaches only its own
devices, never as root, and with no browser check. Check mode asked again every
12 hours, which herdr's background connection to the Mac mini (a saved machine,
see the README's herdr plugins) can't answer. Homebrew upgrades re-block
`mosh-server` in the firewall; a root daemon re-allows it on its own, and a
daily check notifies if that ever fails.

---

## 16. Confirm the setup with `dotfiles doctor`

Bootstrap ends by running it, so its list of problems is the manual steps still
left. Once the steps above are done, run it again:

```
dotfiles doctor
```

It checks everything the README's `dotfiles doctor` row lists, from Tailscale
SSH and the firewall to the LaunchAgents (work hours on laptops only) and
Screen Sharing (on for the Mac mini, off on laptops). Anything wrong
comes with the command that fixes it. `dotfiles update` and the daily run end
with it too; run it again whenever something seems off.

---

## Remaining Gaps vs Omarchy

Omarchy's desktop shell runs on [Quickshell](https://quickshell.org) and Hyprland, so a large part of it has no macOS analogue and is out of scope here: the shell process itself, the Hyprland configs, the ISO installer, pacman packaging, and the PAM fingerprint flows. Another tier is already native — Vicinae covers the launcher, clipboard manager and emoji picker, and macOS provides Notification Center, Control Center and Touch ID.

What is left worth tracking:

| Omarchy | macOS |
|---|---|
| `SUPER + O` — float & pin | ✅ Option+O floats, centres and carries the window to every workspace; it isn't kept above other windows |
| `SUPER + G` — window grouping | No AeroSpace equivalent |
| `SUPER + Ctrl + F` — tiled full screen (the app goes full screen inside its tile) | No macOS equivalent: an app's full screen always takes the whole display |
| `SUPER` + left/right drag — move and resize windows with the mouse | No AeroSpace equivalent. Easy Move+Resize can add it, but was tried and dropped: it fought AeroSpace's tiling, and taking over every Option + click breaks Option-click and Option-drag in other apps (copying in Finder, downloading links in Chrome) |
| `SUPER + SHIFT + arrows` — swap window | Option+Ctrl+arrows (remapped to free Option+Shift for word selection) |
| Window position save/restore per workspace | No AeroSpace equivalent |
| `SUPER + L` / `SUPER + ALT + L` — cycle the workspace layout either way, floating included | Option+L and Option+Cmd+L toggle tiles and accordion only, so both chords do the same. AeroSpace floats windows, not workspaces: an `on-window-detected` rule with `if.workspace` floats new windows only, so moved-in ones stay tiled. Not set up, since AeroSpace can't arrange floating windows. Option+T toggles one window |
| Per-monitor independent workspaces | Aerospace handles it, less seamless |
| Bar transparency and repositioning by double-click and drag | No SketchyBar equivalent; height and position are set in `sketchybarrc` |
| Agents widget | ✅ Agents item, reading each tool's own login where that tool keeps it: Claude Code and Cursor from the keychain, Grok from `~/.grok/auth.json`, Codex through `codex app-server`. An agent that isn't installed or signed in is left out, as in Omarchy. Antigravity has no source yet: `agy` isn't signed in here, so where it keeps its login on macOS is unknown. Not ported: the rotating stats line (tokens, top model, busiest day), multi-account switching and its notifications, the starter-prompt tiles, sign-in from the panel, cross-machine sync and drag to reorder. SketchyBar rows have no hover tooltips, so the percentage is always shown. Right-click starts `claude --permission-mode auto` in `~/Work`, as Omarchy launches agents |
| Microphone state indicator | ✅ Mic item, visible while muted |
| Stay-awake indicator | ✅ Stay awake item, tracks caffeinate |
| Queued reminder indicator | ✅ Reminder item, with the count when there are several |
| Weather beside the clock | ✅ Weather item, via wttr.in; click opens the forecast in Ghostty rather than a popup |
| Bar clicks and scrolling on workspaces, audio, clock, power and agents | ✅ Ported. The clock's middle-click timezone picker and the agents widget's subscription switch have no counterpart |
| Microphone widget: scroll for input volume | Not ported. The mic item shows only while muted, and muting here sets input volume to 0, so the first scroll tick would unmute it and hide the item under the cursor. It also bypasses the level `mic-mute.sh` restores |
| `SUPER + SHIFT + Space` — hide the bar | Not ported. Hiding SketchyBar alone leaves AeroSpace's top gap as an empty strip; reclaiming it means rewriting the gap as `fullscreen-desktop.sh` does, teaching `sync_aerospace_gap.sh` about it, and keeping the two toggles from undoing each other. Option+Ctrl+Cmd+F hides the bar with the gaps |
| Bluetooth widget: right-click toggles the radio | Not ported; needs `blueutil` |
| Display widget: scroll for brightness | Not ported. Command-line brightness tools are unreliable on Apple Silicon and reach only the built-in screen |
| Media widget (now playing) | Not ported. macOS 15.4 locked down the interface the command-line players relied on |
| Tray | Not ported; the macOS menu bar is the tray |
| Do not disturb, night light, screen recording, dictation and remote session indicators | Not ported. Focus and Night Shift state can't be read reliably without Full Disk Access or private interfaces, and macOS shows its own recording and dictation indicators. A remote session indicator wasn't attempted |
| Herdr layouts (`hdl`/`hds`/`hdlm`/`hsl`) | ✅ Ported to zsh in `stow/zsh/.config/zsh/aliases/herdr.zsh` |
| Coding agents Omarchy declares as lazy mise tools | ✅ Declared the same way in `stow/macos/.config/mise/conf.d/agents.toml`, Claude Code, Codex, OpenCode and Cursor CLI included, with Omarchy's mise settings in `omarchy.toml` beside it (its `cursor-agent` alias exposes only the launcher) |
| Omarchy's other default mise tools (`uv`, `playwright`, `ghui`, `hey-cli`, `cf`, the `basecamp` CLI) | ✅ Declared the same way in `stow/macos/.config/mise/conf.d/tools.toml`; `gh` and `hunk` stay in the Brewfile |
| Theming every tool from Omarchy's templates (`default/themed`), which retint when the theme changes | ✅ Fixed to Tokyo Night, the only theme here: Grok (`theme = "tokyonight"` set in `~/.grok/config.toml` by `install/dotfiles/grok.sh`, the rest of that file left to Grok), Claude Code (Omarchy's template rendered into `~/.claude/themes/omarchy.json`), gum's prompts (`GUM_*` in `gum.zsh`), hunk and OpenCode follow the terminal palette. Ghostty, herdr, tmux, Neovim, btop, Vicinae, SketchyBar and JankyBorders already were; bat, lazygit, starship and eza use the terminal's colors. pi's theme isn't ported: it installs on first run and its settings file is its own |
| `~/Work` as the work directory, with `~/Work/tries` and `try` | ✅ `install/dotfiles/work-dir.sh` moves `~/Code` to `~/Work` on bootstrap or `dotfiles update`, on either OS, and leaves `~/Code` linking to it; `try` comes from the Brewfile, initialized in zsh as Omarchy's bash init does. The public installer at dotfiles.sogamo.so (the `installer` branch) clones into `~/Work`, and on a machine not yet moved updates its `~/Code` checkout for bootstrap to move |
| Omarchy's `h` and `mup` aliases | ✅ `h` in `herdr.zsh`, `mup` in the `mise` alias pair |
| Per-agent accounts (`omarchy-agent-account-*`), which switch an agent between logins | Not ported. `dotfiles agent run` starts each agent with Omarchy's flags but on its single default login |
| Devin CLI and Kiro CLI | Not ported. Omarchy's mise entries download Linux builds only. Add them once mise can fetch Apple Silicon builds on demand |
| Agents updating themselves every four hours (mise `auto_update`) | ✅ By another route: on mise 2026.10.19 `auto_update` breaks how the shim calls the agent, so the `com.sogamoso.agents-update` LaunchAgent runs `mise upgrade` on the installed agents every four hours. Retry `auto_update` after a mise upgrade |
| SSH reconnect and terminal cleanup on drop | ✅ Omarchy's `ssh` wrapper, ported in `stow/zsh/.config/zsh/omarchy/fns/ssh-reconnect.zsh`: a dropped interactive session gets its mouse tracking and alternate screen disarmed and reconnects, and keepalives surface a dead link in ~45s |
| Themes generating nvim/btop/VS Code colors from one colorset | No generator. `themes/tokyo-night/colors.toml` is the palette to copy by hand into apps without a Tokyo Night theme, Slack included |
| Visual theme and background switchers | No equivalent |
| `SUPER + Ctrl + A/B/W` — audio/bluetooth/wifi TUIs | ✅ Option+Ctrl+A/B/W → System Settings |
| `SUPER + Ctrl + D` / `P` — display and power panels | ✅ Option+Ctrl+D/P → Displays and Battery settings (Energy on a desktop Mac) |
| `SUPER + Ctrl + S` — share menu (clipboard, file or folder over LocalSend) | Option+Ctrl+S opens LocalSend itself; pick what to send there |
| `SUPER + Ctrl + X` — dictation, and holding Right Alt to talk | ✅ Right ⌘ → MacWhisper: hold to talk (set by `preferences.sh`) |
| `SUPER + Ctrl + Z` — screen zoom | Use macOS Accessibility zoom |
| `Shift + CapsLock` — Compose key, typing emojis from two letters (`m s` → 😄) | Not ported. macOS has no system-wide Compose key: `DefaultKeyBinding.dict` sequences only reach native Cocoa text fields, not Chrome, Electron apps or terminals. Option+Ctrl+E opens the emoji picker |
| `SUPER + C/V` — copy/paste | Cmd+C/V already works on macOS |
| `SUPER + ALT + SHIFT + F` — file manager at terminal cwd | Not mapped; `open .` in the shell does the same. A port needs `aerospace list-windows --focused --format '%{app-pid}'` plus `lsof -d cwd` (no `/proc` on macOS), and the parent-child descent misses the shell entirely under tmux or herdr |
| `SUPER + SHIFT + G` — Signal | Not mapped; Signal is not installed. Option+Shift+G opens WhatsApp, which upstream puts on `SUPER + SHIFT + ALT + G` |
| `SUPER + SHIFT + CTRL + G` — Google Messages | Not mapped; no PWA installed |
| `SUPER + SHIFT + P` — Google Photos | Not mapped; no PWA installed |
| `SUPER + SHIFT + ALT + M` — cliamp music TUI | No macOS equivalent; Spotify is on Option+Shift+M |
| `SUPER + SHIFT + ALT + A` — Grok | Option+Shift+Cmd+A opens ChatGPT instead |
