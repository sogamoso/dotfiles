# macOS → Omarchy UX Setup Guide
## Exact Keybinding Parity with Omarchy's Hyprland + tmux

The goal: build identical muscle memory so moving to an Omarchy machine is frictionless.

---

## The Key Mapping Strategy

Omarchy uses `SUPER` as the primary modifier. On a Mac keyboard, the physical key in the same position is `Cmd` (⌘). The problem is macOS claims `Cmd` for system shortcuts (Cmd+C, Cmd+V, Cmd+Q, etc.).

**Solution: Use Karabiner-Elements to swap `Cmd` and `Ctrl` at the hardware level.**

After the swap:
- Physical `Cmd` key → sends `Ctrl` to macOS (your Omarchy "SUPER" for Aerospace)
- Physical `Ctrl` key → sends `Cmd` to macOS (for Cmd+C, Cmd+V, etc.)

Your fingers hit the same physical key for `SUPER` on both Omarchy and macOS. The trade-off: copy/paste moves to the physical Ctrl key position, but since Linux uses `Ctrl+C`/`Ctrl+V` anyway, this actually aligns too.

---

## Phase 1: Karabiner-Elements — Swap Cmd/Ctrl

1. Install:
   ```bash
   brew install --cask karabiner-elements
   ```

2. Open Karabiner-Elements, grant accessibility + input monitoring permissions.

3. Go to **Simple Modifications** tab and add:

   | From key | To key |
   |----------|--------|
   | `left_command` | `left_control` |
   | `left_control` | `left_command` |
   | `right_command` | `right_control` |
   | `right_control` | `right_command` |

4. Test: Physical Cmd key should now act as Ctrl. Physical Ctrl should do Cmd things (try physical-Ctrl+C to copy).

**After this swap, Aerospace binds to `ctrl-*` in its config = physical Cmd key = SUPER on Omarchy.**

---

## Phase 2: Aerospace — Tiling Window Manager

Omarchy uses Hyprland's **dwindle layout** with `force_split = 2` (always splits to the right/bottom) and `preserve_split = true`. This creates the Fibonacci-like spiral pattern where each new window takes half the remaining space.

**Aerospace equivalent:** With both normalizations enabled (`enable-normalization-flatten-containers` and `enable-normalization-opposite-orientation-for-nested-containers`), Aerospace automatically alternates split orientation for nested containers — which produces the same dwindle/Fibonacci behavior. First window fills the screen, second splits horizontally, third splits the right half vertically, fourth splits that bottom-right horizontally, and so on.

1. Install:
   ```bash
   brew install --cask nikitabobko/tap/aerospace
   ```

2. Launch Aerospace, grant accessibility permissions.

3. Create config:
   ```bash
   mkdir -p ~/.config/aerospace
   ```

4. Write `~/.config/aerospace/aerospace.toml`:

```toml
# =============================================================
# Aerospace config — 1:1 Omarchy/Hyprland keybinding parity
# =============================================================
# After Karabiner Cmd↔Ctrl swap:
#   Physical Cmd key = ctrl in config = SUPER on Omarchy
#   Physical Ctrl key = cmd in config
#   Physical Alt/Option = alt in config = ALT on Omarchy
# =============================================================

after-login-command = []
after-startup-command = []

# CRITICAL: Both normalizations enabled = dwindle/Fibonacci tiling
# This matches Hyprland's "layout = dwindle" used by Omarchy.
# - flatten-containers: no redundant nesting (single-child containers removed)
# - opposite-orientation: nested containers auto-alternate H/V split direction
#   → produces the Fibonacci spiral pattern as you open more windows
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

# Gaps — Omarchy uses gaps_in=5, gaps_out=10
[gaps]
inner.horizontal = 5
inner.vertical = 5
outer.left = 10
outer.bottom = 10
outer.top = 10
outer.right = 10

# -------------------------------------------------------
# Main keybindings
# -------------------------------------------------------
[mode.main.binding]

# === WORKSPACE SWITCHING ===
# Omarchy: SUPER + 1-9,0
ctrl-1 = 'workspace 1'
ctrl-2 = 'workspace 2'
ctrl-3 = 'workspace 3'
ctrl-4 = 'workspace 4'
ctrl-5 = 'workspace 5'
ctrl-6 = 'workspace 6'
ctrl-7 = 'workspace 7'
ctrl-8 = 'workspace 8'
ctrl-9 = 'workspace 9'
ctrl-0 = 'workspace 10'   # Also serves as pseudo-scratchpad

# === MOVE WINDOW TO WORKSPACE (follow focus) ===
# Omarchy: SUPER + SHIFT + 1-9,0
ctrl-shift-1 = 'move-node-to-workspace 1'
ctrl-shift-2 = 'move-node-to-workspace 2'
ctrl-shift-3 = 'move-node-to-workspace 3'
ctrl-shift-4 = 'move-node-to-workspace 4'
ctrl-shift-5 = 'move-node-to-workspace 5'
ctrl-shift-6 = 'move-node-to-workspace 6'
ctrl-shift-7 = 'move-node-to-workspace 7'
ctrl-shift-8 = 'move-node-to-workspace 8'
ctrl-shift-9 = 'move-node-to-workspace 9'
ctrl-shift-0 = 'move-node-to-workspace 10'

# === FOCUS NAVIGATION ===
# Omarchy: SUPER + arrow keys
ctrl-left = 'focus left'
ctrl-right = 'focus right'
ctrl-up = 'focus up'
ctrl-down = 'focus down'

# === SWAP/MOVE WINDOWS ===
# Omarchy: SUPER + SHIFT + arrow keys
ctrl-shift-left = 'move left'
ctrl-shift-right = 'move right'
ctrl-shift-up = 'move up'
ctrl-shift-down = 'move down'

# === WINDOW CONTROLS ===
# Omarchy: SUPER + W = close window
ctrl-w = 'close'

# Omarchy: SUPER + F = fullscreen
ctrl-f = 'fullscreen'

# Omarchy: SUPER + T = toggle floating
ctrl-t = 'layout floating tiling'

# Omarchy: SUPER + J = toggle split direction
ctrl-j = 'layout tiles horizontal vertical'

# === WORKSPACE CYCLING ===
# Omarchy: SUPER + TAB / SUPER + SHIFT + TAB
ctrl-tab = 'workspace next'
ctrl-shift-tab = 'workspace prev'

# === RESIZE ===
# Omarchy: SUPER + minus/equals
ctrl-minus = 'resize width -50'
ctrl-equal = 'resize width +50'
ctrl-shift-minus = 'resize height -50'
ctrl-shift-equal = 'resize height +50'

# === APP LAUNCHERS ===
# Omarchy: SUPER + RETURN = terminal
ctrl-enter = 'exec-and-forget open -na Ghostty'

# Omarchy: SUPER + SHIFT + N = editor
ctrl-shift-n = 'exec-and-forget open -na Zed'

# Omarchy: SUPER + SHIFT + RETURN = browser
ctrl-shift-enter = 'exec-and-forget open -na "Google Chrome"'

# Omarchy: SUPER + L = toggle workspace layout
ctrl-l = 'layout tiles accordion'

# -------------------------------------------------------
# Window rules (auto-assign apps to workspaces)
# 1: Chrome | 2: Ghostty | 3: Slack | 4: Gmail
# 5: Calendar | 6: Notion | 7: Spotify | 8: YouTube
# 9: (free) | 10: scratchpad
# -------------------------------------------------------
[[on-window-detected]]
if-app-id = 'com.google.Chrome'
run = 'move-node-to-workspace 1'

[[on-window-detected]]
if-app-id = 'com.mitchellh.ghostty'
run = 'move-node-to-workspace 2'

[[on-window-detected]]
if-app-id = 'com.tinyspeck.slackmacgap'
run = 'move-node-to-workspace 3'

# Gmail (Chrome PWA)
[[on-window-detected]]
if-app-id = 'com.google.Chrome.app.fmgjjmmmlfnkbppncabfkddbjimcfncm'
run = 'move-node-to-workspace 4'

# Google Calendar (Chrome PWA)
[[on-window-detected]]
if-app-id = 'com.google.Chrome.app.kjbdgfilnfhdoflbpgamdcdgpehopbep'
run = 'move-node-to-workspace 5'

[[on-window-detected]]
if-app-id = 'notion.id'
run = 'move-node-to-workspace 6'

[[on-window-detected]]
if-app-id = 'com.spotify.client'
run = 'move-node-to-workspace 7'

# YouTube (Chrome PWA)
[[on-window-detected]]
if-app-id = 'com.google.Chrome.app.agimnkijcaahngcdmfeangaknmldooml'
run = 'move-node-to-workspace 8'
```

5. Reload:
   ```bash
   aerospace reload-config
   ```

6. **Test the dwindle layout:** Open 4 windows on one workspace. You should see:
   - Window 1: full screen
   - Window 2: splits screen 50/50 horizontally
   - Window 3: splits the right half vertically
   - Window 4: splits the bottom-right quadrant horizontally

   This is the Fibonacci spiral — same as Omarchy.

---

## Phase 3: AltTab (Window Cycling)

Omarchy uses `ALT + TAB` to cycle through windows on the active workspace. macOS's native Cmd+Tab is hijacked by Aerospace for workspace cycling. AltTab restores proper window cycling on the same physical key.

1. Install:
   ```bash
   brew install --cask alt-tab
   ```

2. Open AltTab, grant accessibility permissions.

3. In AltTab preferences:
   - Set hotkey to `Option+Tab` (this is `Alt+Tab` — same physical key as on Omarchy)
   - Under **Appearance**, set to show windows from "Visible Spaces" only (matches Hyprland's per-workspace cycling)
   - Under **Controls**, set Shift+Option+Tab for reverse cycling (matches Omarchy's `ALT+SHIFT+TAB`)

---

## Phase 4: Neutralize macOS Interference

**System Settings:**

1. **Desktop & Dock → Mission Control:**
   - OFF: "Automatically rearrange Spaces based on most recent use"
   - OFF: "When switching to an application, switch to a Space with open windows"

2. **Desktop & Dock → Windows** (Sequoia+):
   - OFF: "Tile by dragging windows to screen edges"

3. **Keyboard → Keyboard Shortcuts → Mission Control:**
   - Uncheck ALL (Ctrl+Up, Ctrl+Down, Switch to Desktop 1/2/3, etc.)

4. **Keyboard → Keyboard Shortcuts → Spotlight:**
   - Uncheck Cmd+Space

5. **Control Center → Menu Bar:**
   - "Automatically hide and show the menu bar" → "Always"

**Terminal:**

```bash
defaults write com.apple.dock workspaces-swoosh-animation-off -bool YES
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
killall Dock
```

---

## Phase 5: Raycast (App Launcher)

Omarchy: `SUPER + SPACE` → Walker. Same physical combo → Raycast.

1. Install:
   ```bash
   brew install --cask raycast
   ```

2. Raycast Settings → Set hotkey to `Ctrl+Space` (physical Cmd+Space after swap).

3. Disable Spotlight: System Settings → Keyboard → Keyboard Shortcuts → Spotlight → Uncheck all.

---

## Phase 6: Terminal + tmux (Alacritty + Ghostty + omadots)

### 6a. Back Up Existing Configs

omadots **overwrites** the following files and directories. Back them all up before running the installer:

```bash
# Create a timestamped backup directory
BACKUP=~/dotfiles-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP"

# Shell configs (omadots replaces these entirely)
cp -v ~/.zshrc "$BACKUP/" 2>/dev/null
cp -v ~/.zprofile "$BACKUP/" 2>/dev/null
cp -v ~/.bashrc "$BACKUP/" 2>/dev/null
cp -v ~/.bash_profile "$BACKUP/" 2>/dev/null
cp -v ~/.inputrc "$BACKUP/" 2>/dev/null

# Config directories (omadots copies over these)
cp -rv ~/.config/tmux "$BACKUP/" 2>/dev/null      # tmux config
cp -rv ~/.config/nvim "$BACKUP/" 2>/dev/null       # replaced with LazyVim starter
cp -rv ~/.config/git "$BACKUP/" 2>/dev/null        # git config
cp -rv ~/.config/shell "$BACKUP/" 2>/dev/null      # shell aliases/envs/functions
cp -rv ~/.config/starship.toml "$BACKUP/" 2>/dev/null  # starship prompt
cp -rv ~/.config/mise "$BACKUP/" 2>/dev/null       # mise runtime config
cp -rv ~/.config/btop "$BACKUP/" 2>/dev/null       # btop config
cp -rv ~/.config/opencode "$BACKUP/" 2>/dev/null   # opencode config

echo "Backed up to $BACKUP"
ls -la "$BACKUP"
```

> **What omadots does NOT touch:** Alacritty, Aerospace, Karabiner, SketchyBar, Raycast configs. Those are safe.

### 6b. Install Alacritty + Ghostty

Both are managed by this repo's Brewfile (`brew bundle`). Both use Tokyo Night colors matched to Omarchy's exact palette.

**Alacritty config** (`~/.config/alacritty/alacritty.toml`):
```toml
[env]
TERM = "xterm-256color"

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
size = 12

[window]
padding.x = 18
padding.y = 18
decorations = "buttonless"
option_as_alt = "Both"

[colors]
[colors.primary]
background = '#1a1b26'
foreground = '#a9b1d6'

[colors.normal]
black = '#32344a'
red = '#f7768e'
green = '#9ece6a'
yellow = '#e0af68'
blue = '#7aa2f7'
magenta = '#ad8ee6'
cyan = '#449dab'
white = '#787c99'

[colors.bright]
black = '#444b6a'
red = '#ff7a93'
green = '#b9f27c'
yellow = '#ff9e64'
blue = '#7da6ff'
magenta = '#bb9af7'
cyan = '#0db9d7'
white = '#acb0d0'

[colors.selection]
background = '#7aa2f7'
```

**Ghostty config** is stow-managed at `stow/macos/.config/ghostty/config` in this repo. The built-in `tokyonight` theme is used — no manual palette needed. The `macos-titlebar-style = transparent` + `macos-window-buttons = hidden` combo is Ghostty's equivalent of Alacritty's `decorations = "buttonless"`.

### 6c. Install tmux + omadots

```bash
brew install tmux
```

Run the omadots installer:

```bash
bash <(curl -sL https://raw.githubusercontent.com/omacom-io/omadots/master/install.sh)
```

**What this installs to `~/.config`:** tmux, shell (aliases/envs/functions/inits), starship.toml, git, nvim (LazyVim starter), mise, btop, opencode.

### 6d. tmux Prefix — The Karabiner Interaction

The omadots/Omarchy tmux prefix is `Ctrl+Space` (`C-Space`).

After the Karabiner Cmd↔Ctrl swap:
- Physical **Cmd+Space** → sends `Ctrl+Space` to macOS → intercepted by Raycast
- Physical **Ctrl+Space** → sends `Cmd+Space` to macOS

Inside Alacritty, terminal key handling should pass `C-Space` correctly regardless of the macOS-level swap — terminal emulators read raw scancodes. **Test this first.** If the prefix doesn't work, add this to your Alacritty config:

```toml
[keyboard]
bindings = [
  { key = "Space", mods = "Command", chars = "\x00" }  # Send C-Space (NUL) to tmux
]
```

The fallback prefix `C-b` is always available (omadots sets `prefix2 = C-b`).

### 6e. Customization Layer

Create a local override file so `git pull` on omadots won't clobber your additions:

```bash
echo 'source-file -q ~/.config/tmux/tmux.local.conf' >> ~/.config/tmux/tmux.conf
touch ~/.config/tmux/tmux.local.conf
```

Starter `~/.config/tmux/tmux.local.conf`:
```bash
# Your customizations on top of omadots/Omarchy defaults

# Tokyo Night theme override (replaces omadots' default blue theme)
set -g status-style "bg=default,fg=default"
set -g status-left "#[fg=#1a1b26,bg=#7aa2f7,bold] #S #[bg=default] "
set -g status-right "#[fg=#7aa2f7]#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=#444b6a]#h "
set -g window-status-format "#[fg=#444b6a] #I:#W "
set -g window-status-current-format "#[fg=#7aa2f7,bold] #I:#W "
set -g pane-border-style "fg=#32344a"
set -g pane-active-border-style "fg=#7aa2f7"
set -g message-style "bg=default,fg=#7aa2f7"
set -g message-command-style "bg=default,fg=#7aa2f7"
set -g mode-style "bg=#7aa2f7,fg=#1a1b26"
setw -g clock-mode-colour "#7aa2f7"

# Zoom pane toggle (built-in tmux, making it explicit)
bind z resize-pane -Z

# Add your own bindings below
```

### 6f. Starship prompt

omadots includes a `starship.toml` config, just install the binary:

```bash
brew install starship
```

The omadots shell config loads it automatically.

---

## Phase 7: SketchyBar (Status Bar)

Omarchy uses Waybar. SketchyBar is the macOS equivalent.

1. Install:
   ```bash
   brew tap FelixKratz/formulae
   brew install sketchybar
   brew services start sketchybar
   mkdir -p ~/.config/sketchybar/plugins
   ```

2. Config (`~/.config/sketchybar/sketchybarrc`):
   ```bash
   #!/bin/bash

   # Tokyo Night colors
   # background: #1a1b26 → 0xff1a1b26
   # foreground: #a9b1d6 → 0xffa9b1d6
   # accent (blue): #7aa2f7 → 0xff7aa2f7
   # dim: #444b6a → 0xff444b6a
   # dark: #32344a → 0xff32344a

   sketchybar --bar \
     height=32 \
     blur_radius=30 \
     position=top \
     sticky=on \
     padding_left=10 \
     padding_right=10 \
     color=0xff1a1b26

   sketchybar --default \
     icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
     label.font="JetBrainsMono Nerd Font:Regular:13.0" \
     icon.color=0xffa9b1d6 \
     label.color=0xffa9b1d6 \
     padding_left=5 \
     padding_right=5

   for i in $(seq 1 9); do
     sketchybar --add item space.$i left \
       --set space.$i \
         associated_space=$i \
         icon=$i \
         icon.padding_left=8 \
         icon.padding_right=8 \
         background.color=0xff7aa2f7 \
         background.corner_radius=5 \
         background.height=22 \
         background.drawing=off \
         script="~/.config/sketchybar/plugins/space.sh" \
       --subscribe space.$i space_change
   done

   sketchybar --add item clock right \
     --set clock update_freq=30 script="~/.config/sketchybar/plugins/clock.sh"

   sketchybar --add item battery right \
     --set battery update_freq=120 script="~/.config/sketchybar/plugins/battery.sh"

   sketchybar --update
   ```

3. Plugins:

   **`~/.config/sketchybar/plugins/space.sh`:**
   ```bash
   #!/bin/bash
   if [ "$SELECTED" = "true" ]; then
     sketchybar --set $NAME background.drawing=on icon.color=0xff1a1b26
   else
     sketchybar --set $NAME background.drawing=off icon.color=0xffa9b1d6
   fi
   ```

   **`~/.config/sketchybar/plugins/clock.sh`:**
   ```bash
   #!/bin/bash
   sketchybar --set $NAME label="$(date '+%H:%M')"
   ```

   **`~/.config/sketchybar/plugins/battery.sh`:**
   ```bash
   #!/bin/bash
   PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
   sketchybar --set $NAME label="${PERCENTAGE}%"
   ```

4. Finalize:
   ```bash
   chmod +x ~/.config/sketchybar/plugins/*.sh
   sketchybar --reload
   ```

---

## Complete Keybinding Reference

### Layer 1: Window Management (Aerospace)

All use the **physical Cmd key** (= SUPER on Omarchy).

| Action | Omarchy (Hyprland) | macOS (Aerospace) | Physical keys |
|---|---|---|---|
| Workspace 1-9,0 | `SUPER + 1-9,0` | `ctrl-1` to `ctrl-0` | Cmd + number |
| Move window to workspace | `SUPER + SHIFT + 1-9,0` | `ctrl-shift-1` to `ctrl-shift-0` | Cmd + Shift + number |
| Focus left/right/up/down | `SUPER + arrows` | `ctrl-arrows` | Cmd + arrow |
| Swap window direction | `SUPER + SHIFT + arrows` | `ctrl-shift-arrows` | Cmd + Shift + arrow |
| Close window | `SUPER + W` | `ctrl-w` | Cmd + W |
| Fullscreen | `SUPER + F` | `ctrl-f` | Cmd + F |
| Toggle floating | `SUPER + T` | `ctrl-t` | Cmd + T |
| Toggle split | `SUPER + J` | `ctrl-j` | Cmd + J |
| Next/prev workspace | `SUPER + TAB/S-TAB` | `ctrl-tab/s-tab` | Cmd + Tab |
| Resize width | `SUPER + -/=` | `ctrl-minus/equal` | Cmd + -/= |
| Toggle layout | `SUPER + L` | `ctrl-l` | Cmd + L |
| App launcher | `SUPER + SPACE` | Raycast | Cmd + Space |
| Terminal | `SUPER + RETURN` | `ctrl-enter` | Cmd + Enter |
| Browser | `SUPER + SHIFT + RETURN` | `ctrl-shift-enter` | Cmd + Shift + Enter |
| Editor | `SUPER + SHIFT + N` | `ctrl-shift-n` | Cmd + Shift + N |
| Cycle windows | `ALT + TAB` | AltTab | Alt + Tab |
| Scratchpad | `SUPER + S` | `ctrl-0` (workspace 10) | Cmd + 0 |

### Layer 2: tmux (Inside Terminal)

Prefix = `Ctrl+Space`. Identical on Omarchy and macOS.

| Action | Keys | Prefix? |
|---|---|---|
| Split horizontal | `prefix + h` | Yes |
| Split vertical | `prefix + v` | Yes |
| Kill pane | `prefix + x` | Yes |
| Navigate panes | `Ctrl+Alt+Arrow` | No |
| Resize panes | `Ctrl+Alt+Shift+Arrow` | No |
| Window 1-9 | `Alt+1-9` | No |
| Prev/next window | `Alt+Left/Right` | No |
| Swap window order | `Alt+Shift+Left/Right` | No |
| New window | `prefix + c` | Yes |
| Kill window | `prefix + k` | Yes |
| Rename window | `prefix + r` | Yes |
| New session | `prefix + C` | Yes |
| Kill session | `prefix + K` | Yes |
| Prev/next session | `prefix + P/N` or `Alt+Up/Down` | Mixed |
| Rename session | `prefix + R` | Yes |
| Reload config | `prefix + q` | Yes |
| Copy mode | `prefix + [` | Yes |
| Begin selection | `v` (in copy mode) | — |
| Copy & exit | `y` (in copy mode) | — |

### Layer 3: System (macOS after Karabiner swap)

Standard macOS shortcuts use the **physical Ctrl key** (which sends Cmd to macOS).

| Action | Physical keys | What macOS sees |
|---|---|---|
| Copy | Ctrl + C | Cmd + C |
| Paste | Ctrl + V | Cmd + V |
| Undo | Ctrl + Z | Cmd + Z |
| Save | Ctrl + S | Cmd + S |
| Quit app | Ctrl + Q | Cmd + Q |

> **Closing vs quitting:** Physical Cmd+W closes the focused window via Aerospace (matches Omarchy's `SUPER+W`). Physical Ctrl+Q sends `Cmd+Q` to macOS to quit an entire app — no Omarchy equivalent, just standard macOS behavior you already know.

---

## Verification Checklist

- [ ] Physical Cmd key triggers Aerospace (Cmd+1 = workspace 1)
- [ ] Physical Ctrl key does macOS copy/paste
- [ ] Cmd+Space opens Raycast
- [ ] Cmd+Enter opens Ghostty
- [ ] Cmd+Tab cycles workspaces (not macOS app switcher)
- [ ] Alt+Tab cycles windows via AltTab
- [ ] Opening 4 windows produces Fibonacci/dwindle spiral layout
- [ ] Cmd+0 toggles to workspace 10 (pseudo-scratchpad)
- [ ] Inside terminal, `Ctrl+Space` activates tmux prefix
- [ ] `Alt+1-9` switches tmux windows
- [ ] `Ctrl+Alt+Arrow` navigates tmux panes
- [ ] tmux status bar shows at top with Tokyo Night theme
- [ ] Starship prompt is active in shell
- [ ] No Spaces animation on workspace switch
- [ ] Dock and menu bar are hidden
- [ ] SketchyBar shows workspace indicators with Tokyo Night colors
- [ ] All terminals, tmux, SketchyBar, and Zed share the same Tokyo Night palette

---

## Workspace Layout

| Workspace | App | Notes |
|---|---|---|
| 1 | Chrome | Regular browser windows |
| 2 | Ghostty | Primary terminal |
| 3 | Slack | |
| 4 | Gmail | Chrome PWA |
| 5 | Google Calendar | Chrome PWA |
| 6 | Notion | |
| 7 | Spotify | |
| 8 | YouTube | Chrome PWA |
| 9 | (free) | Ad-hoc use |
| 10 | Scratchpad | Cmd+0 to toggle |

---

## Tokyo Night Everywhere Else

The terminal configs, tmux, and SketchyBar above all use Omarchy's exact Tokyo Night values. Here's how to apply it to the rest of your stack:

**Zed:** Settings → Theme → search "Tokyo Night". The built-in `Tokyo Night` theme is available out of the box.

**Starship prompt:** omadots includes a `starship.toml`. Terminal palette colors 0–15 map to the Tokyo Night values set in Alacritty/Ghostty automatically.

**Slack:** Preferences → Themes → paste this custom theme:
`#1a1b26,#32344a,#7aa2f7,#a9b1d6,#444b6a,#a9b1d6,#9ece6a,#7aa2f7,#1a1b26,#a9b1d6`

**btop:** If omadots installs a btop config, copy Omarchy's theme:
```bash
# If you have Omarchy's repo cloned for reference:
cp themes/tokyo-night/btop.theme ~/.config/btop/themes/tokyo-night.theme
```
Then set `color_theme = "tokyo-night"` in `~/.config/btop/btop.conf`.

**LazyVim (nvim):** Add to `~/.config/nvim/lua/plugins/colorscheme.lua`:
```lua
return {
  { "folke/tokyonight.nvim", opts = { style = "night" } },
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight-night" } },
}
```

### Tokyo Night Color Reference

| Role | Hex | Usage |
|---|---|---|
| Background | `#1a1b26` | Primary background everywhere |
| Foreground | `#a9b1d6` | Default text |
| Accent | `#7aa2f7` | Active indicators, links, highlights |
| Cursor | `#c0caf5` | Cursor, bright text |
| Selection BG | `#7aa2f7` | Selected text background |
| Selection FG | `#c0caf5` | Selected text foreground |
| Dim | `#444b6a` | Inactive text, subtle borders |
| Dark | `#32344a` | Darker backgrounds, borders |
| Red | `#f7768e` | Errors, warnings |
| Green | `#9ece6a` | Success, additions |
| Yellow | `#e0af68` | Warnings, search highlights |
| Magenta | `#bb9af7` | Keywords, special elements |
| Cyan | `#0db9d7` | Info, secondary accent |

---

## Remaining Gaps (No Clean macOS Equivalent)

| Omarchy Feature | macOS Status |
|---|---|
| `SUPER + O` — pop window out (float & pin) | Float only via Cmd+T, no pin-on-top |
| `SUPER + G` — window groups/tabs | Accordion layout is closest |
| `SUPER + SHIFT + SPACE` — toggle waybar | No toggle for SketchyBar via hotkey |
| `SUPER + K` — show keybindings | Reference this doc |
| `SUPER + mouse drag` — move/resize | Keyboard resize only |
| `SUPER + CTRL + F` — tiled fullscreen | No equivalent |
| `SUPER + ALT + F` — full width | No equivalent |
| `SUPER + P` — pseudo window | No equivalent |
| `SUPER + COMMA` — dismiss notification | macOS notification center |
| Web app wrappers (nativefier) | Safari "Add to Dock" |
