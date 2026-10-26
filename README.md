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
  mise/                    # mise config (node + ruby via latest); the macOS agents and tools are in macos/.config/mise/conf.d
  nvim/                    # Neovim plugin overrides
  ruby/                    # .gemrc, .irbrc, .default-gems
  ssh/                     # SSH client config + signing key
  zsh/                     # .zshrc, .zprofile, the zsh port of Omarchy's shell, supplement + per-tool aliases (macOS; bash twin lives in linux/)
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

`install/dotfiles/skills.sh` handles three sources, in this order:

| Source | Holds | How |
| --- | --- | --- |
| `stubs/` in sogamoso/uidotsh-archive | The `ui`, `brand-kit` and `markup-from-image` stubs | linked |
| [sogamoso/skills](https://github.com/sogamoso/skills) | Personal skills | plugin |
| [sendasorg/cheque](https://github.com/sendasorg/cheque) | cheque: delivering approved Linear issues through Pstack | plugin, for the user in both agents |

Both repos are private and cloned over SSH, since they get pushed to — so a
locked 1Password agent will skip them with a warning rather than fail the run.
A plugin source is registered from its repo's https URL, not its checkout, so
each agent fetches its own copy and the skills land on a machine that cloned
nothing. Reading them needs no SSH agent. The clone is there because it's a repo to
work in, not because the plugin depends on it.

A source that ships plugin manifests for **both** agents — `.claude-plugin/` and
`.agents/plugins/` — is installed as a plugin instead of linked. Plugins
namespace their skills and each agent updates them natively, which is strictly
better than symlinks. A source packaged for one agent only stays linked, so the
two agents don't end up calling the same skill by different names. The packaging
decides the mechanism, not a list in the script.

[mattpocock/skills](https://github.com/mattpocock/skills) is the exception: it
only ships a Claude plugin, and it is only used in Claude Code, so it is installed
by `claude-code.sh` with the other Claude plugins (`/mattpocock-skills:tdd`) and
Codex doesn't get it.

The ui.sh stubs live in the private archive repo, not here: they're what ui.sh's
installer scaffolds, and its license forbids redistributing that, so they can't
sit in this public repo. The same repo keeps dated snapshots of the full paid
skills in case the subscription lapses.

`skills.sh` switches between the two by itself. Each run makes an MCP handshake
with ui.sh using the license token (no skill is fetched). If ui.sh accepts it, the
stubs are linked and fetch the current skills. If it refuses it (HTTP 401 or 403,
meaning the subscription ended or the token changed), the archive's `restore.py`
builds offline copies from the latest snapshot into its `local/` folder and those
are linked instead, with a notification. Once ui.sh accepts the token again, the
next run deletes `local/` and goes back to the stubs. If access can't be checked
(no token yet, no network, ui.sh down), it keeps whichever is in place.
`uidotsh.sh` runs before `skills.sh` so the token exists for that check.

They stay linked deliberately, rather than packaged as a plugin. Their names collide with nothing, and
there is nothing to update — each is seven lines whose only job is to fetch the
real instructions over MCP. More to the point, ui.sh writes real `SKILL.md`
files into the skills directory itself, so these have to be locally
authoritative: linking lets a rerun reassert the checkout, where a plugin
fetched from a URL would leave the local file and the pushed one disagreeing.
Links remain the right route for anything locally owned and locally rewritten.

Both agents discover skills exactly one level deep, so every link is flat however
the source is organized — categories are free on the source side and invisible on
the agent side. Directories starting with `_` or `.` are scaffolding and are
ignored. Links this repo made and no longer produces are pruned, so renames and
deletions don't leave strays behind.

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
| `dotfiles update` | Pull, sync Brewfile, restow, reload services, install Vicinae extensions added on another Mac, update every installed mise tool (`mise up`, as `omarchy update` does). Also runs daily at 10:30, followed by `dotfiles doctor`, from the `com.sogamoso.dotfiles-daily` agent (skipped on battery). That run only installs new Brewfile entries and leaves upgrades to brew autoupdate, which can ask for a password; a notification gives the result and opens the log at `/tmp/com.sogamoso.dotfiles-daily.log` |
| `dotfiles pull` | Git pull only |
| `dotfiles brew` | Sync Brewfile via `brew bundle`, keep brew autoupdate current |
| `dotfiles stow` | Re-stow all packages |
| `dotfiles reload` | Re-stow, relink skills, restart SketchyBar, reload AeroSpace, restart a stale herdr server |
| `dotfiles status` | Branch, ahead/behind, dirty files |
| `dotfiles doctor` | Check this Mac's setup (Tailscale, SSH, firewall, agents, ui.sh skills, 1Password, Vicinae, brew autoupdate) and print the fix for anything wrong |
| `dotfiles vicinae [status \| save \| reset]` | Compare Vicinae's settings and store extensions with the repo. `save` keeps what changed on this Mac (commit the result), `reset` drops it |
| `dotfiles omarchy-downstream-candidates` | Review what changed in Omarchy since the last review and which of it to port, in Claude Code (Codex if Claude isn't installed) with the `omarchy-downstream` skill. `--list` prints the raw changes: new and removed key bindings, commits touching what the macOS side ports, files added or removed outside the areas set aside as Linux-only, new migrations that mention something used here, and any Omarchy area not yet classified as ported or skipped. `--mark-reviewed` records the review in `.omarchy-reviewed` |
| `dotfiles agent [<name>]` | Show or set the default coding agent, like Omarchy's `omarchy default agent`, with the same names (`gemini` picks Antigravity, `cursor` the Cursor CLI). The `a` alias launches it with Omarchy's flags for that agent, and the herdr layouts use it when no agent is given |
| `dotfiles edit` | Open the repo in `$VISUAL` |

Set `$DOTFILES` to override the repo location (default: `~/Work/sogamoso/dotfiles`). Work lives in `~/Work`, as on Omarchy, with `~/Work/tries` for `try`; `install/dotfiles/work-dir.sh` moves an older `~/Code` there on bootstrap or `dotfiles update` and leaves `~/Code` linking to it.

### Dotfiles setup

The dotfiles setup (`install/dotfiles/all.sh`) runs these scripts in order:

| Script | What it does |
|--------|-------------|
| `hushlogin.sh` | Suppresses "Last login" terminal message |
| `coderabbit.sh` | Configures git filter to strip Coderabbit config from `.gitconfig` |
| `aerospace-gap.sh` | Configures git filter to pin the sketchybar-rewritten `outer.top` gap |
| `claude-code.sh` | Installs Claude Code marketplaces, plugins, and configures claude-hud |
| `codex.sh` | Installs the third-party Codex marketplaces and plugins |
| `uidotsh.sh` | Registers the [ui.sh](https://ui.sh) MCP server with Claude Code and Codex, and caches its token where the shells can export it |
| `skills.sh` | Links every skill into both `~/.claude/skills` and `~/.codex/skills` — see [Skills](#skills) |

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
| `omadots.sh` | Installs [Omadots](https://github.com/omacom-io/omadots) for LazyVim; the shell, tmux and starship configs come from Omarchy's, ported in the stow packages |
| `security.sh` | Turns off Remote Login (SSH goes through Tailscale SSH), hardens sshd, enables the firewall |
| `brew.sh` | Installs all packages from `Brewfile` |
| `onepassword.sh` | Opens 1Password for sign-in and SSH agent setup |
| `../dotfiles/stow.sh` | Stows the cross-platform packages plus `zsh` and `macos` into `$HOME` |
| `preferences.sh` | macOS system defaults |
| `pwas.sh` | Installs Chrome PWAs (Audible, Gmail, Google Calendar, X, YouTube) |
| `mailto.sh` | Builds the Gmail `mailto:` handler and sets it as the system default |
| `sketchybar.sh` | Configures SketchyBar status bar |
| `~/.config/dotfiles/firewall.sh` | Lets the current `tailscaled` and `mosh-server` through the macOS firewall and restarts a `tailscaled` left on an old binary. Upgrades re-block them, so `--install` adds a root LaunchDaemon (`com.sogamoso.firewall-sync`) that does this after every Homebrew upgrade, running a root-owned copy from `/usr/local/libexec/dotfiles`. A daily user-level `--check` (`com.sogamoso.firewall-check`) notifies if that ever fails |
| `tailscale.sh` | Starts Tailscale and turns on Tailscale SSH, waiting up to 5 minutes for the browser sign-in on a new machine |
| `aerospace.sh` | Starts AeroSpace only if not already running |
| `vicinae.sh` | Points Vicinae's `settings.json` at the stowed `dotfiles.json`, installs the store extensions in `extensions.txt`, then launches it |
| `neovim.sh` | Builds `~/Applications/Neovim.app`, which opens files in Neovim in a new Ghostty window, and makes it the default for text and code file types (via `duti`) |
| `manual_steps.sh` | Opens the manual setup guide, first run only |

#### Workspace layout

| Workspace | Purpose | Apps |
|---|---|---|
| 1 | Browse | Chrome, Safari |
| 2 | Dev | Ghostty |
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
| Workspaces 1–9 | Focused workspace; click to switch, scroll to step through them as Option + Tab does | Always |
| Clock | Date and time (centered when an external display is attached); click opens Google Calendar, right-click switches format | Always |
| Weather | Conditions and temperature from wttr.in, beside the clock; click opens the forecast, right-click notifies the full reading, middle-click refreshes | Once a fetch succeeds |
| CPU, Wi-Fi, Bluetooth | System state | Always |
| Input source | Active keyboard layout; click switches it | While more than one is enabled |
| Volume | Output volume; click opens Sound settings, right-click mutes, scroll changes it | Always |
| Battery | Charge, plus time remaining under 20%; click opens Battery settings, right-click toggles the percentage | While discharging or charging |
| Mic | Microphone is muted; click toggles | While muted |
| Reminder | A reminder is queued, with the count when there are several; click lists them | While queued |
| Stay awake | A caffeinate assertion is held (workhours or manual) | While held |
| Claude usage | Spend and time left in the active billing block, via `ccusage`; click shows every block, right-click starts Claude Code | While a block is active |
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
| `Option + Space` | Vicinae launcher |
| `Option + Escape` | Apple menu |
| `Option + K` | Hotkeys cheatsheet (Vicinae) |
| `Option + Shift + K` | Neovim cheatsheet (Vicinae) |
| `Option + 1-9` | Switch to workspace 1–9 |
| `Option + S` | Switch to scratchpad (workspace 10) |
| `Option + Tab` | Next workspace |
| `Option + Shift + Tab` | Previous workspace |
| `Option + Ctrl + Tab` | Switch to former workspace |
| `Option + arrows` | Focus window left/right/up/down |
| `Option + Ctrl + arrows` | Swap window with its neighbour |
| `Option + Shift + 1-9` | Move window to workspace and follow |
| `Option + Shift + S` | Move window to scratchpad (workspace 10) and follow |
| `Option + Shift + Cmd + 1-9` | Move window to workspace without following |
| `Option + Shift + Cmd + S` | Move window to scratchpad without following |
| `Option + W` | Close focused window |
| `Option + Q` | Close focused window (second chord, as in Omarchy) |
| `Option + M` | Minimize window to the Dock |
| `Ctrl + Cmd + Del` | Close all windows, jump to workspace 1 |
| `Option + F` | Full screen (macOS native: hides the bar, own Space). Window keys pressed while in it leave full screen first, then act |
| `Option + Cmd + F` | Full width: fill the workspace, keep the bar |
| `Option + Ctrl + Cmd + F` | Full screen desktop: hide the bar and drop window gaps (toggle) |
| `Option + T` | Toggle floating/tiling |
| `Option + O` | Pop window out: float, centre and pin it to every workspace (toggle) |
| `Option + J` | Toggle split direction |
| `Option + L` | Toggle layout |
| `Option + Cmd + L` | Toggle layout (Omarchy's reverse cycle; same toggle with two layouts) |
| `Option + - / =` | Resize width |
| `Option + Shift + - / =` | Resize height |
| `Option + B` | Balance window sizes |

##### Launching apps

| Hotkey | Action |
|---|---|
| `Option + Enter` | New Ghostty window |
| `Option + Shift + Enter` | New Chrome window |
| `Option + Shift + N` | Neovim in a new Ghostty window |
| `Option + Shift + C` | Open Google Calendar |
| `Option + Shift + E` | Open Gmail |
| `Option + Shift + G` | Open WhatsApp |
| `Option + Shift + M` | Open Spotify |
| `Option + Shift + O` | Open Obsidian |
| `Option + Shift + F` | Open Finder |
| `Option + Shift + /` | 1Password Quick Access (1Password's own shortcut, set in its settings) |
| `Option + Shift + A` | Open Claude |
| `Option + Shift + Y` | Open YouTube |
| `Option + Shift + B` | New Chrome window |
| `Option + Shift + W` | Open Typora |
| `Option + Shift + X` | Open X |
| `Option + Shift + Cmd + X` | New X post |
| `Option + Shift + Cmd + A` | Open ChatGPT |
| `Option + Shift + Cmd + B` | Chrome incognito |
| `Option + Cmd + Enter` | Ghostty + tmux session |

##### System controls

| Hotkey | Action |
|---|---|
| `Option + Ctrl + L` | Lock screen |
| `Option + Ctrl + A` | Sound preferences |
| `Option + Ctrl + B` | Bluetooth preferences |
| `Option + Ctrl + W` | Wi-Fi preferences |
| `Option + Shift + T` | btop in Ghostty |
| `Option + Ctrl + S` | LocalSend: share files with Omarchy and phones |
| `Option + Ctrl + V` | Clipboard history (Vicinae) |
| `Option + Ctrl + E` | Emoji picker (Vicinae) |
| `Right ⌘` | Dictation: hold to talk (MacWhisper) |
| `Option + I` | Switch input language |
| `Option + Shift + I` | Switch input language back |
| `Mic Mute (F18)` | Toggle microphone mute (Lofree mic-mute key; dead on built-in keyboard) |

##### Status notifications

| Hotkey | Action |
|---|---|
| `Option + Ctrl + Cmd + T` | Time, date, ISO week (notification) |
| `Option + Ctrl + Cmd + B` | Battery level + state (notification) |
| `Option + Ctrl + Cmd + W` | Weather from wttr.in (notification) |
| `Option + Ctrl + Cmd + E` | World clock: Panama City, Tegucigalpa, Mexico City, San Francisco, New York (notification) |

##### Secure Input

While macOS Secure Input is active no other app can read key events, so every
AeroSpace hotkey goes dead and AeroSpace shows its "cannot respond to keyboard
shortcuts" panel. Run **Secure Input** from Vicinae (or
`~/.config/dotfiles/secure-input.sh` in a terminal) to name the app holding it
— usually a focused password field, Terminal's Secure Keyboard Entry, or the
lock screen. Quitting or defocusing that app is the only fix; nothing can
release it from outside.

It has no hotkey on purpose: AeroSpace reads keys through an event tap, which
is exactly what Secure Input blocks, so a binding would be dead when needed.
The Vicinae launcher still opens, because Vicinae registers `Option + Space`
itself rather than through AeroSpace.

| Hotkey | Action |
|---|---|
| `Vicinae → Secure Input` | Name the app holding Secure Input |

##### Capture

| Hotkey | Action |
|---|---|
| `Option + Ctrl + C` | CleanShot all-in-one |
| `Cmd + Shift + 3` | CleanShot capture fullscreen |
| `Cmd + Shift + 4` | CleanShot capture area |
| `Cmd + Shift + 5` | CleanShot all-in-one |
| `Cmd + Shift + 6` | CleanShot OCR text extraction |

##### Reminders

Ephemeral kitchen-timer-style reminders (die on logout/reboot).

| Hotkey | Action |
|---|---|
| `Option + Ctrl + R` | Set Reminder (prompts for minutes + message in Vicinae) |
| `Option + Ctrl + Cmd + R` | Show Reminders |
| `Option + Ctrl + Shift + R` | Clear Reminders |

##### Notifications

| Hotkey | Action |
|---|---|
| `Option + ,` | Toggle Notification Center |
| `Option + Shift + Cmd + ,` | Toggle Notification Center |
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

##### tmux

Prefix is `Ctrl + Space`.

| Hotkey | Action |
|---|---|
| `prefix + h / v` | Split horizontal / vertical |
| `prefix + x / k` | Kill pane / window |
| `prefix + c` | New window |
| `prefix + r / R` | Rename window / session |
| `prefix + [` | Copy mode (`v` select, `y` copy) |
| `Cmd + 1-9` | Switch window |
| `Cmd + Left/Right` | Previous / next window |
| `Cmd + Up/Down` | Previous / next session |

##### tmux layouts

The tmux twins of the herdr review layouts, from the same [`layouts.zsh`](stow/zsh/.config/zsh/aliases/layouts.zsh). They run inside a tmux pane.

| Command | Layout |
|---|---|
| `trl [<agent>]` | Review layout: agent left half, hunk diff watch top right, terminal bottom right |
| `trlm [<agent>]` | One window per subdirectory, each running `trl`; the current window takes the first |
| `trw [<name>] [<agent>] [<task>]` | New agent on its own worktree off `origin/main`, in a new window running `trl`, with branches named and tasks passed as in `hrw`. Checkouts go under `~/.herdr/worktrees`, where herdr would put them |
| `trd` | Finish the agent in this window: confirm, delete its branch, remove its worktree and close the window |

##### herdr

Agent multiplexer. Prefix is `Ctrl + Space`; the Command-key chords replicate the tmux-style navigation (`Cmd + arrows` for tabs and workspaces), except `Cmd + digits`, which jump to agents. Config lives in [`stow/macos/.config/herdr/config.toml`](stow/macos/.config/herdr/config.toml).

| Hotkey | Action |
|---|---|
| `prefix + v / -` | Split pane right / down |
| `Ctrl + Cmd + arrows` | Focus pane |
| `Ctrl + Cmd + Shift + arrows` | Resize pane |
| `prefix + z / x` | Zoom / close pane |
| `prefix + r / [` | Resize mode / copy mode (`v` select, `y` copy) |
| `prefix + c` | New tab |
| `Cmd + 1-9` | Jump to agent 1–9, in workspace order; on Omarchy `Alt + 1-9` |
| `prefix + 1-9` | Switch tab |
| `Cmd + Left/Right` | Previous / next tab |
| `Cmd + Shift + Left/Right` | Move tab left / right |
| `Cmd + Up/Down` | Previous / next workspace (also `prefix + Shift + P/N`) |
| `prefix + w / b` | Workspace picker / toggle sidebar |
| `prefix + q / ?` | Detach / show all bindings |
| `prefix + a` | New agent on its own worktree (`hrw`) for the focused pane's repo |
| `prefix + Shift + A` | New agent on a task: pick the agent, type the task and an optional branch (`hra`) |
| `prefix + f` | Finish the focused agent: confirm, then delete its branch and worktree (`hrd`) |
| `prefix + o` | Jump to the agent that last raised a notification, the latest one waiting on you (herdr default) |
| `prefix + Shift + 1-9` | Switch to workspace 1–9, and so to an agent, since each agent has its own (herdr default) |

##### herdr layouts

Shell functions that build a whole herdr layout in one command. They run inside a herdr pane. The `hd*` and `hsl` ones are ported from Omarchy and live in [`stow/zsh/.config/zsh/aliases/herdr.zsh`](stow/zsh/.config/zsh/aliases/herdr.zsh). The `hr*` review layouts are this repo's own, so they ship for both shells in [`stow/zsh/.config/zsh/aliases/layouts.zsh`](stow/zsh/.config/zsh/aliases/layouts.zsh) and its bash twin. With no agent given they run the default agent through `a` when one is set (`omarchy default agent` on Omarchy, `dotfiles agent` on macOS), and `cx` otherwise.

| Command | Layout |
|---|---|
| `hdl <agent> [<agent2>]` | Editor left, agent in a 30% column right, terminal strip along the bottom |
| `hds` | 2×2: editor, hunk diff watch, terminal, opencode |
| `hdlm <agent> [<agent2>]` | One `hdl` tab per subdirectory of the current directory |
| `hsl <count> <command>` | Tile into a grid and run the same command in every pane |
| `hrl [<agent>]` | Review layout: agent left half, hunk diff watch top right, terminal bottom right |
| `hrlm [<agent>]` | One workspace per subdirectory, each with a single `hrl` tab; the current workspace takes the first |
| `hrw [<name>] [<agent>] [<task>]` | New agent on its own worktree off `origin/main`: a worktree workspace, grouped under the repo, running `hrl`, with the mise config trusted. Without a name the branch is named after the harness: `claude-1` for `cx`, `codex-1` for `cy`, `opencode-1` for `c`, `cursor-1`, `gemini-1`, any agent Omarchy's `omarchy default agent` offers, or `agent-1` for anything else. A task becomes the agent's first prompt. Also on `prefix + a` |
| `hra` | Ask for the agent, task and branch, then run `hrw`. Also on `prefix + Shift + A` |
| `hrd` | Finish the agent whose workspace this is: confirm, delete its branch, remove its worktree and close the workspace, like Omarchy's `gd`. Also on `prefix + f` |

#### Manual setup guide

For the manual setup guide including Privacy & Security settings, Vicinae, and Tokyo Night theming: [`docs/macos-manual-setup.md`](docs/macos-manual-setup.md).

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
| `../dotfiles/stow.sh` | Stows the cross-platform packages plus `linux`, taking `~/.config/hypr/bindings.lua` over from `/etc/skel` |
| `bashrc.sh` | Appends the personal supplement source to `.bashrc` |
| `herdr-keys.sh` | Adds the agent keys (`prefix + a`, `prefix + Shift + A`, `prefix + f`) to Omarchy's herdr config |

#### What gets customized

| Area | Approach |
|---|---|
| Keybindings | `~/.config/hypr/bindings.lua` — only the app deltas, via `o.rebind` / `o.bind` |
| Shell | `~/.config/bash/supplement.bash` plus per-tool aliases, sourced from Omarchy's own bashrc slot |
| Theme | Stock `tokyo-night`; Omarchy already ships it and the colors match |
| Bar, menu, notifications | Omarchy stock — nothing ported |
| herdr | Omarchy's config, plus the agent keys appended by an Omarchy `post-update.d` hook, so they come back if an update replaces the file. The keys match the macOS ones |

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

#### What is deliberately not ported

- **`herdr.zsh`** — Omarchy ships `default/bash/fns/herdr` natively. The zsh file is a hand-port for macOS; re-porting it would shadow the real thing.
- **Typora** — `Super + Shift + W` keeps Omarchy's Omawrite. Typora is a macOS habit, not a reason to add a package here.
- **sketchybar plugins and Vicinae script commands** — Omarchy's bar and `omarchy menu` already cover reminders, the keybinding cheatsheet, and system toggles.
- **ghostty, btop, git, lazygit configs** — Omarchy ships its own and rewrites them on every theme switch. Stowing the macOS versions would fight its theming.
- **The herdr config** — Omarchy ships its own, following the terminal's palette, and only `omarchy-refresh-herdr` replaces it. Only the agent keys are added to it (see above).
