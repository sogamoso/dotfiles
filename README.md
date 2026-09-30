# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

```
curl -fsSL https://dotfiles.sogamo.so/install | bash
```

Safe to run multiple times. The bootstrap script is idempotent.

## Stow directory

Each folder under `stow/` is a stow package. Running `stow --target $HOME --restow <package>` symlinks its contents into `$HOME`.

```
stow/
  claude/                  # Claude Code settings, keybindings, and status line
  codex/                   # Codex AGENTS.md (points at the Claude Code instructions)
  editorconfig/            # .editorconfig
  git/                     # .gitconfig, global .gitignore, SSH allowed signers
  linux/                   # Omarchy-only configs (stowed only on Linux)
  macos/                   # macOS-only configs (stowed only on Darwin)
  mise/                    # mise config (node + ruby via latest)
  nvim/                    # Neovim plugin overrides
  ruby/                    # .gemrc, .irbrc, .default-gems
  ssh/                     # SSH client config + signing key
  zsh/                     # Shell supplement + per-tool aliases (macOS; bash twin lives in linux/)
```

### How it works

`bootstrap` runs two phases:

1. **OS setup** — dispatches by `uname -s`.
2. **Dotfiles** (`install/dotfiles/all.sh`) — cross-platform config symlinks via stow.

After both phases it drops into a fresh login shell — zsh on macOS, bash on Omarchy.

## Skills

Claude Code and Codex both read `<skills-dir>/<name>/SKILL.md`, so each skill is
linked into `~/.claude/skills` and `~/.codex/skills` from a single source and the
two agents stay in step by construction. Skills are deliberately not a stow
package: stow lands a package in one place, and these need two.

`install/dotfiles/skills.sh` handles four sources, in this order:

| Source | Holds | How |
| --- | --- | --- |
| `skills/` in this repo | Grouped by category — `uidotsh/` holds the `ui`, `brand-kit` and `markup-from-image` stubs | linked |
| [sogamoso/skills](https://github.com/sogamoso/skills) | Personal skills | plugin |
| [sendasorg/skills](https://github.com/sendasorg/skills) | Sendas work skills | plugin |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Third-party set, minus its `in-progress/` staging area | linked |

Both personal repos are public but cloned over SSH, since they get pushed to — so
a locked 1Password agent will skip them with a warning rather than fail the run.
A plugin source is registered from its repo's https URL, not its checkout, so
each agent fetches its own copy and the skills land on a machine that cloned
nothing. Reading them needs no SSH agent. The clones are there because these are
repos to work in, not because the plugins depend on them.

A source that ships plugin manifests for **both** agents — `.claude-plugin/` and
`.agents/plugins/` — is installed as a plugin instead of linked. Plugins
namespace their skills and each agent updates them natively, which is strictly
better than symlinks. Packaging for one agent only is worse than neither, since
it would namespace on that side and not the other, so those stay linked until
upstream catches up; mattpocock ships a Claude plugin and lists a Codex one as a
roadmap item, so it will switch over on its own. The packaging decides the
mechanism, not a list in the script.

The `uidotsh/` stubs stay linked deliberately, rather than this repo being
packaged as a marketplace of its own. Their names collide with nothing, and
there is nothing to update — each is seven lines whose only job is to fetch the
real instructions over MCP. More to the point, ui.sh writes real `SKILL.md`
files into the skills directory itself, so these have to be locally
authoritative: linking lets a rerun reassert the checkout, where a plugin
fetched from a URL would leave the local file and the pushed one disagreeing.
Links remain the right route for anything locally owned and locally rewritten.

Both agents discover skills exactly one level deep, so every link is flat however
the source is organized — categories are free on the source side and invisible on
the agent side. They key on the directory name alone, so the first source to
claim a name keeps it, and a later source offering that name is reported and
skipped rather than silently winning. Directories starting with `_` or `.` are
scaffolding and are ignored.

Some names are reserved in `skills.sh` because something outside this repo
already answers to them — today just `code-review`, which Claude Code ships as an
unqualified built-in. A source wanting a reserved name has its skill linked under
the source's prefix instead (`mattpocock-code-review`), so nothing is lost and
the built-in keeps its name. That list is explicit rather than detected from
what's installed: which plugins are present varies per machine, and the link
names must not. A collision with a plugin skill that isn't reserved is reported
and otherwise left alone, so a new one surfaces on the next bootstrap without
quietly changing behavior. Links this repo made and no longer produces are
pruned, so renames and upstream deletions don't leave strays behind.

The three ui.sh skills are stubs that fetch their real instructions over MCP, so
they only work where `uidotsh.sh` has registered that server. It registers with
both agents; Codex reads the bearer token from `$UIDOTSH_TOKEN`, which the shell
supplements export from `~/.local/state/dotfiles/uidotsh.env`.

Codex started from ChatGPT.app inherits the launchd session environment rather
than a shell's, so on macOS the `com.sogamoso.uidotsh-token` agent republishes
the token there at login. That makes it readable by every GUI process in the
session via `launchctl getenv`, which is wider than the 0600 file it comes from —
fine for a personal ui.sh token, not a pattern to reuse for anything with a
larger blast radius.

## CLI

A `dotfiles` command is installed to `~/.local/bin/dotfiles` for day-to-day maintenance:

| Command | Action |
|---|---|
| `dotfiles update` | Pull, sync Brewfile, restow, reload services |
| `dotfiles pull` | Git pull only |
| `dotfiles brew` | Sync Brewfile via `brew bundle` |
| `dotfiles stow` | Re-stow all packages |
| `dotfiles reload` | Re-stow, relink skills, restart SketchyBar, reload AeroSpace, restart a stale herdr server |
| `dotfiles status` | Branch, ahead/behind, dirty files |
| `dotfiles edit` | Open the repo in `$VISUAL` |

Set `$DOTFILES` to override the repo location (default: `~/Code/sogamoso/dotfiles`).

### Dotfiles setup

The dotfiles setup (`install/dotfiles/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `ssh.sh` | Ensures `~/.ssh` directory exists before stowing |
| `stow.sh` | Stows cross-platform dotfile packages into `$HOME` |
| `zshrc.sh` | Appends personal supplement source to `.zshrc` |
| `hushlogin.sh` | Suppresses "Last login" terminal message |
| `coderabbit.sh` | Configures git filter to strip Coderabbit config from `.gitconfig` |
| `aerospace-gap.sh` | Configures git filter to pin the sketchybar-rewritten `outer.top` gap |
| `claude-code.sh` | Installs Claude Code marketplaces, plugins, and configures claude-hud |
| `skills.sh` | Links every skill into both `~/.claude/skills` and `~/.codex/skills` — see [Skills](#skills) |
| `uidotsh.sh` | Registers the [ui.sh](https://ui.sh) MCP server with Claude Code and Codex, and caches its token where the shells can export it |

## Cross-platform design

The stow packages under `stow/` are cross-platform by default.

Two patterns keep configs portable:

- **Git**: `.gitconfig` uses `[include] path = ~/.config/git/config.macos`. Git silently ignores the include if the file doesn't exist (i.e. on Linux).
- **Shell**: `supplement.zsh` conditionally sources `supplement.macos.zsh` only if the file is readable. On Linux, the macOS stow package won't be installed so the file won't exist.
- **Shells differ by OS**: macOS runs zsh, Omarchy runs bash. The `zsh` package is stowed only on Darwin; its bash counterpart ships in the `linux` package. See AGENTS.md for the rule that keeps the two in sync.

### macOS

Heavily inspired by [Omarchy](https://github.com/basecamp/omarchy), built on top of [Omadots](https://github.com/omacom-io/omadots). Works on a fresh macOS install with no prior tooling. The installer bootstraps everything from scratch — shell framework, packages, and dotfile symlinks.

The macOS setup (`install/macos/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `xcode.sh` | Checks for Xcode Command Line Tools, opens installer if missing, then exits for rerun after install |
| `omadots.sh` | Installs [Omadots](https://github.com/omacom-io/omadots) shell framework |
| `security.sh` | Enables SSH/firewall and applies sshd hardening |
| `brew.sh` | Installs all packages from `Brewfile` |
| `onepassword.sh` | Opens 1Password for sign-in and SSH agent setup |
| `dotfiles.sh` | Stows all dotfile packages into `$HOME` |
| `tmux.sh` | Installs TPM (tmux plugin manager) if missing |
| `preferences.sh` | macOS system defaults |
| `pwas.sh` | Installs Chrome PWAs (Audible, GitHub, Gmail, Google Calendar, X, YouTube) |
| `mailto.sh` | Builds the Gmail `mailto:` handler and sets it as the system default |
| `sketchybar.sh` | Configures SketchyBar status bar |
| `tailscale.sh` | Starts Tailscale daemon and connects with SSH enabled |
| `aerospace.sh` | Starts AeroSpace only if not already running |
| `raycast.sh` | Opens Raycast for first-time setup |
| `zed.sh` | Sets Zed as the default editor for text and code file types (via `duti`) |
| `manual_steps.sh` | Opens the manual setup guide, first run only |

#### Workspace layout

| Workspace | Purpose | Apps |
|---|---|---|
| 1 | Browse | Chrome, Safari |
| 2 | Dev | Ghostty, Zed |
| 3 | Chat | Slack, WhatsApp, Discord |
| 4 | Mail & calendar | Gmail, Google Calendar |
| 5 | Other work apps | Notion |
| 6 | Misc | Whatever |
| 7 | Entertainment | Spotify, Podcasts |
| 8–9 | Misc | Whatever |
| 10 | Scratchpad | Temporary |

#### Status bar

SketchyBar, configured in [`stow/macos/.config/sketchybar/`](stow/macos/.config/sketchybar/). The left side holds the launcher anchor and workspace indicators, the right side holds status items. Several stay hidden until they have something to report, so the bar is quiet when everything is normal.

| Item | Shows | Visible |
|---|---|---|
| Workspaces 1–9 | Focused workspace | Always |
| Clock | Date and time (centered when an external display is attached) | Always |
| CPU, volume, Wi-Fi, Bluetooth, input source | System state | Always |
| Battery | Charge, plus time remaining under 20% | While discharging |
| Mic | Microphone is muted; click toggles | While muted |
| Stay awake | A caffeinate assertion is held (workhours or manual) | While held |
| Claude usage | Spend and time left in the active billing block, via `ccusage` | While a block is active |
| Dotfiles update | Commits behind origin; click runs `dotfiles update` | While behind |

#### Hotkeys

Follows [Omarchy](https://github.com/basecamp/omarchy)'s Hyprland keybinding model on macOS.

| Physical key | macOS sends | Role | Omarchy equivalent |
|---|---|---|---|
| Option | Alt/Option | Window management | Super |
| Command | Cmd | App shortcuts + tmux | Alt |

##### Navigating

| Hotkey | Action |
|---|---|
| `Option + Space` | Raycast launcher |
| `Option + Escape` | Apple menu (Raycast) |
| `Option + K` | Hotkeys cheatsheet (Raycast) |
| `Option + 1-9` | Switch to workspace 1–9 |
| `Option + S` | Switch to scratchpad (workspace 10) |
| `Option + Tab` | Next workspace |
| `Option + Shift + Tab` | Previous workspace |
| `Option + Ctrl + Tab` | Switch to former workspace |
| `Option + arrows` | Focus window left/right/up/down |
| `Option + Ctrl + arrows` | Move window within workspace |
| `Option + Shift + 1-9` | Move window to workspace and follow |
| `Option + Shift + S` | Move window to scratchpad (workspace 10) and follow |
| `Option + Shift + Cmd + 1-9` | Move window to workspace without following |
| `Option + Shift + Cmd + S` | Move window to scratchpad without following |
| `Option + W` | Close focused window |
| `Ctrl + Cmd + Del` | Close all windows, jump to workspace 1 |
| `Option + F` | Fullscreen |
| `Option + T` | Toggle floating/tiling |
| `Option + J` | Toggle split direction |
| `Option + L` | Toggle layout |
| `Option + - / =` | Resize width |
| `Option + Shift + - / =` | Resize height |
| `Option + B` | Balance window sizes |

##### Launching apps

| Hotkey | Action |
|---|---|
| `Option + Enter` | New Ghostty window |
| `Option + Shift + Enter` | New Chrome window |
| `Option + Shift + N` | New Zed window |
| `Option + Shift + C` | Open Google Calendar |
| `Option + Shift + E` | Open Gmail |
| `Option + Shift + G` | Open WhatsApp |
| `Option + Shift + M` | Open Spotify |
| `Option + Shift + O` | Open Obsidian |
| `Option + Shift + F` | Open Finder |
| `Option + Shift + /` | Open 1Password |
| `Option + Shift + A` | Open Claude |
| `Option + Shift + Y` | Open YouTube |
| `Option + Shift + B` | New Chrome window |
| `Option + Shift + W` | Open Typora |
| `Option + Shift + X` | Open X |
| `Option + Shift + Cmd + X` | New X post |
| `Option + Shift + Cmd + A` | Open ChatGPT |
| `Option + Shift + I` | Open Notion |
| `Option + Shift + L` | Open Linear |
| `Option + Shift + D` | LazyDocker in Ghostty |
| `Option + Shift + Cmd + B` | Chrome incognito |
| `Option + Cmd + Enter` | Ghostty + tmux session |

##### System controls

| Hotkey | Action |
|---|---|
| `Option + Ctrl + L` | Lock screen |
| `Option + Ctrl + A` | Sound preferences |
| `Option + Ctrl + B` | Bluetooth preferences |
| `Option + Ctrl + W` | Wi-Fi preferences |
| `Option + Ctrl + T` | btop in Ghostty |
| `Option + Ctrl + V` | Clipboard history (Raycast) |
| `Option + Ctrl + E` | Emoji picker (Raycast) |
| `Option + Ctrl + X` | Monologue (dictation) |
| `Mic Mute (F14)` | Toggle microphone mute (Lofree mic-mute key; dead on built-in keyboard) |

##### Status notifications

| Hotkey | Action |
|---|---|
| `Option + Ctrl + Cmd + T` | Time, date, ISO week (notification) |
| `Option + Ctrl + Cmd + B` | Battery level + state (notification) |
| `Option + Ctrl + Cmd + W` | Weather from wttr.in (notification) |

##### Secure Input

While macOS Secure Input is active no other app can read key events, so every
AeroSpace hotkey goes dead and AeroSpace shows its "cannot respond to keyboard
shortcuts" panel. Run **Secure Input** from Raycast (or
`~/.config/dotfiles/secure-input.sh` in a terminal) to name the app holding it
— usually a focused password field, Terminal's Secure Keyboard Entry, or the
lock screen. Quitting or defocusing that app is the only fix; nothing can
release it from outside.

It has no hotkey on purpose: AeroSpace reads keys through an event tap, which
is exactly what Secure Input blocks, so a binding would be dead when needed.

##### Capture

| Hotkey | Action |
|---|---|
| `Option + Ctrl + C` | CleanShot all-in-one |
| `Cmd + Shift + 3` | CleanShot capture fullscreen (assigned inside CleanShot) |
| `Cmd + Shift + 4` | CleanShot capture area (assigned inside CleanShot) |
| `Cmd + Shift + 5` | CleanShot all-in-one (assigned inside CleanShot) |
| `Cmd + Shift + 6` | CleanShot OCR text extraction (assigned inside CleanShot) |

##### Reminders

Ephemeral kitchen-timer-style reminders (die on logout/reboot).

| Hotkey | Action |
|---|---|
| `Option + Ctrl + R` | Set Reminder (Raycast — prompts for minutes + message) |
| `Option + Ctrl + Cmd + R` | Show Reminders (Raycast) |
| `Option + Ctrl + Shift + R` | Clear Reminders (Raycast) |

##### Notifications

| Hotkey | Action |
|---|---|
| `Option + ,` | Toggle Notification Center |
| `Option + Ctrl + ,` | Toggle Do Not Disturb |

##### Ghostty

| Hotkey | Action |
|---|---|
| `Ctrl + Shift + E` | Split down |
| `Ctrl + Shift + O` | Split right |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + 1-9` | Go to tab 1–9 |
| `Ctrl + Shift + Left/Right` | Previous / next tab |
| `Ctrl + Cmd + arrows` | Navigate tmux panes |
| `Ctrl + Cmd + Shift + arrows` | Resize tmux panes |

##### herdr

Agent multiplexer. Prefix is `Ctrl + Space`; the Command-key chords replicate the tmux-style navigation (`Cmd + digits` for tabs, `Cmd + arrows` for tabs and workspaces). Config lives in [`stow/macos/.config/herdr/config.toml`](stow/macos/.config/herdr/config.toml).

| Hotkey | Action |
|---|---|
| `prefix + v / -` | Split pane right / down |
| `prefix + h/j/k/l` | Focus pane (also `Ctrl + Cmd + arrows`) |
| `prefix + z / x` | Zoom / close pane |
| `prefix + r / [` | Resize mode / copy mode (`v` select, `y` copy) |
| `prefix + c` | New tab |
| `Cmd + 1-9` | Switch tab (also `prefix + 1-9`) |
| `Cmd + Left/Right` | Previous / next tab |
| `Cmd + Up/Down` | Previous / next workspace |
| `prefix + w / b` | Workspace picker / toggle sidebar |
| `prefix + q / ?` | Detach / show all bindings |

##### herdr layouts

Shell functions that build a whole herdr layout in one command, ported from Omarchy. They run inside a herdr pane and live in [`stow/zsh/.config/zsh/aliases/herdr.zsh`](stow/zsh/.config/zsh/aliases/herdr.zsh).

| Command | Layout |
|---|---|
| `hdl <agent> [<agent2>]` | Editor left, agent in a 30% column right, terminal strip along the bottom |
| `hds` | 2×2: editor, lazygit, terminal, opencode |
| `hdlm <agent> [<agent2>]` | One `hdl` tab per subdirectory of the current directory |
| `hsl <count> <command>` | Tile into a grid and run the same command in every pane |

#### Manual setup guide

For the manual setup guide including Privacy & Security settings, Raycast, and Tokyo Night theming: [`docs/macos-manual-setup.md`](docs/macos-manual-setup.md).

### Linux (Omarchy)

Targets [Omarchy](https://github.com/omacom/omarchy) 4 "Quattro". Omarchy owns the
desktop: its Quickshell bar, `omarchy menu`, themes, and bash alias/function layer
are used as shipped. These dotfiles only add the deltas.

The macOS side was modelled on Omarchy to begin with, so most of it needs no
translation — workspaces 1–10, tiling, the scratchpad, terminal and browser
bindings all already match upstream.

The Linux setup (`install/linux/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `dotfiles.sh` | Stows the `linux` package, taking `~/.config/hypr/bindings.lua` over from `/etc/skel` |
| `bashrc.sh` | Appends the personal supplement source to `.bashrc` |

#### What gets customized

| Area | Approach |
|---|---|
| Keybindings | `~/.config/hypr/bindings.lua` — only the app deltas, via `o.rebind` / `o.bind` |
| Shell | `~/.config/bash/supplement.bash` plus per-tool aliases, sourced from Omarchy's own bashrc slot |
| Theme | Stock `tokyo-night`; Omarchy already ships it and the colors match |
| Bar, menu, notifications | Omarchy stock — nothing ported |

#### Binding deltas

Everything else matches Omarchy's defaults.

| Binding | Omarchy default | Here |
|---|---|---|
| `Super + Shift + A` | ChatGPT | Claude |
| `Super + Shift + Alt + A` | Grok | ChatGPT |
| `Super + Shift + C` | HEY calendar | Google Calendar |
| `Super + Shift + E` | HEY email | Gmail |
| `Super + Shift + Alt + E` | HEY new email | Gmail compose |
| `Super + Shift + G` | Signal | WhatsApp |
| `Super + Shift + N` | Default editor | Zed |
| `Super + Shift + I` | — | Notion |
| `Super + Shift + L` | — | Linear |

#### What is deliberately not ported

- **`herdr.zsh`** — Omarchy ships `default/bash/fns/herdr` natively. The zsh file is a hand-port for macOS; re-porting it would shadow the real thing.
- **Typora** — `Super + Shift + W` keeps Omarchy's Omawrite. Typora is a macOS habit, not a reason to add a package here.
- **sketchybar plugins and Raycast script commands** — Omarchy's bar and `omarchy menu` already cover reminders, the keybinding cheatsheet, and system toggles.
- **ghostty, btop, herdr, git, lazygit configs** — Omarchy ships its own and rewrites them on every theme switch. Stowing the macOS versions would fight its theming.
